### 背景
目前市面上有很多的 SDK,开发者开发 App 时可以集成各种 SDK 来方便快捷的实现某一部分功能

最近做了 Andorid 和 iOS 的 SDK 测试,做了个小框架,共享出来,和大家一起探讨学习

### SDK 的测试方法
目前大部分的 SDK 测试都是开发一个demo,集成 SDK,然后针对这个 demo 测试以此传参到 SDK 的 api 中.<br>

寻找其他的测试手段,先将 SDK 集成到 demo 中,demo 内置一个 HTTP server,demo 启动时反射扫描被测的 SDK 类,启动 HTTP server,测试人员以约定的参数格式发送 HTTP 请求到 demo 的 server 中,server 反射调用 SDK 对应的接口,返回 同步/异步 接口的返回值,有了返回值就可以用来做断言啦.

### AsheniOS
iOS 因为语言不太熟悉,未找到办法同时获取到参数类型和参数名称,索性写了个 Python 脚本扫描被测的 SDK 的 .h 文件, 使用正则扣出需要的数据,因每人编码习惯不同,场景不同,如果有脚本报错的地方,就需要自己匹配一下,预计的参数格式为

```
{
    "Test.h":[
        {
            "param_type_list":[
                "NSString",
                "int"
            ],
            "param_list":[
                "name",
                "age"
            ],
            "return_type":"NSMutableDictionary",
            "interface_name":"/getUser:age:"
        }
    ]
}
```

启动 App 后,会启动一个 HTTP Server,访问 server 根目录可以访问 App 沙盒.

### 接入方法
1. 在项目中引入 SDK. 安装并执行 `pod install`
2. 编辑项目根目录的 `read_class.py` , 修改变量为被测的 .h 文件,执行文件后会生成 `AshenClass.json`,检查 json 文件内容是否为预期的 json

```
file_name_list = [
    "./AsheniOS/Test.h"
]
```
3. 在 `utils/AshenConst.m` 文件中注册被测类与实例的对应关系

```
ashenConst.ashenClassDic = @{@"Test.h":[Test new]};
```

4. 在 xcode 中, Build Phases 添加一个 build 步骤,拖动到第一步,run script, 写入 `python3 read_class.py`
5. 运行 App, App 中会显示设备的 host,例如 192.168.1.100 , 使用浏览器访问 `http://192.168.1.100:9999/getAllInterface`,就会显示出已注册类的所有函数
6. 实现异步回调接口的 callback. SDK 中可能含有大量的异步回调接口,回调的 callback 可能有很多的中间状态,框架没有办法判断触发了哪一个判断代表了本次接口调用完毕,所以如果是异步接口的话,回调需要用户自己实现.回调在 `utils/AshenCallBack.m` 文件中, 目前的设计中回调分为两种,一种为中间状态,一种为结束状态,根据参数名区分,中间状态不会认为接口执行结束,但是 iOS 没找到办法动态生成 block,所以需要定义两套

```
// 结束状态
-(void) setBlock:(NSMutableDictionary *)blockDic{

    void (^block_NSInteger)(NSInteger arg);
    block_NSInteger = ^(NSInteger arg){
        [[AshenConst sharedConst].ashenResponseDic setValue:@(arg) forKey:@"NSInteger"];
        [AshenConst sharedConst].test_done = YES;
    };
    [blockDic setValue:block_NSInteger forKey:@"block_NSInteger"];
    
    
    void (^block_NSInteger_long)(NSInteger arg,long arg1);
    block_NSInteger_long = ^(NSInteger arg,long arg1){
        [[AshenConst sharedConst].ashenResponseDic setValue:@(arg) forKey:@"NSInteger"];
        [[AshenConst sharedConst].ashenResponseDic setValue:@(arg1) forKey:@"long"];
        [AshenConst sharedConst].test_done = YES;
    };
    [blockDic setValue:block_NSInteger_long forKey:@"block_NSInteger_long"];
    
}
// 中间状态
-(void) setNoReturnBlock:(NSMutableDictionary *)blockDic{
    
    void (^block_NSString)(NSString * arg);
    block_NSString = ^(NSString * arg){
       
    };
    [blockDic setValue:block_NSString forKey:@"block_NSString"];
    
    void (^block_NSInteger_long)(NSInteger arg,long arg1);
    block_NSInteger_long = ^(NSInteger arg,long arg1){
       
    };
    [blockDic setValue:block_NSInteger_long forKey:@"block_NSInteger_long"];
    
}
```

区分是否为结束状态的 block 则是通过 block 的参数名
```
// 包含这些参数名的 block 会被认为是结束状态
ashenCallBack.lastCallBackNameArray = [[NSMutableArray alloc]initWithObjects:@"successBlock",@"errorBlock",@"cancelBlock", nil];
```

### 开始测试

假设我们测试项目中的 Test.h 的 getUser 接口,我们使用浏览器访问

`http://192.168.1.100:9999/getInterfaceParams?name=getUser`

浏览器返回了参数数量,和每个参数的类型

`{"Test.h":[{"param_type_list":["NSString","int"],"param_list":["name","age"],"return_type":"NSMutableDictionary","interface_name":"\/getUser:age:"}]}`

使用 Python 测试这个接口

```
import requests

r = requests.post("http://10.3.3.230:9999/getUser:age:",
                  json={
                      "name": "name",
                      "age": 18
                  })
print(r.text)

```

`{"message":{"name":"name","age":18},"code":200,"time_diff(ms)":0}`

返回数据中的 `{"name":"name","age":18}` 就是实际接口的返回值

### 说明
1. demo 默认的端口设置的为 9999,这个是可以在源码中修改的.
2. 启动的为 HTTP 服务,目前只内置了两个接口,一个是 `/getAllInterface` 获取所有接口,一个是 `/getInterfaceParams?name=methodName` 获取被测接口
3. 本质上是一个 HTTP server,所以可以二次开发给 app 增加更多的接口,也可以直接返回 html,便于用户操作
4. 如果不同的类具有同名同参的接口,则请求增加 `testClassName` 的 key,value 写 文件名.h
5. 对于 json 转对象使用的是 YYModel 库,如果默认转的不符合需求,可以在 `AshenUtil.m` 中的 decode 函数中硬编码, 或者使用 YYModel 转换
6. 项目中关于 HTTP 请求处理的主文件是 `AshenUrls.m`
7. 直接访问 `http://192.168.1.100:9999` 即可访问本 app 的沙盒文件
8. 对于服务端主动推送的消息,可以写一个接口,把消息存到 list 中,需要的时候就返回
9. 如果要测试弱网,则可以使用 tidevice 等工具转发接口 将设备的端口转发到电脑上,这样访问电脑端口测试处在弱网环境的手机
