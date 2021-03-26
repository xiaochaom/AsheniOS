//
//  Util.m
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import "AshenUtil.h"
#import "AshenConst.h"
#import "AshenOrderDictionary.h"
#import <YYModel/YYModel.h>

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
@property (nonatomic, strong) NSMutableDictionary *messageTypeIdentifierMapping;
@end

@implementation AshenUtil

+ (instancetype)shareUtil {
    static AshenUtil *ashenUtil = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ashenUtil = [[AshenUtil alloc] init];
        ashenUtil.ashenInterfaceDic = [self getJsonFileToDic:@"AshenClass.json"];
    });
    return ashenUtil;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic1 = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic1;
}

+ (AshenOrderDictionary *)dictionarySort:(NSDictionary *)oldDic sortArr:(NSArray *)sortArr {
    AshenOrderDictionary* newDic = [AshenOrderDictionary new];
    
    for (NSString* _index in sortArr){
        if ([[oldDic allKeys]containsObject:_index]){
            [newDic setValue:[oldDic valueForKey:_index] forKey:_index];
        }
    }
    return newDic;
}


+ (NSDictionary *)getJsonFileToDic:(NSString *)jsonname
{
    NSString *path = [[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:jsonname];
    //    NSString *path = [[NSBundle mainBundle] pathForResource:jsonname ofType:@"geojson"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSError *error;
    NSDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!jsonData || error) {
        //DLog(@"JSON解码失败");
        return nil;
    } else {
        return jsonDic;
    }
}

+(NSDictionary *)get_response:(NSDictionary *)dic{
    UInt64 timer = ashenTimeOutNum;
    NSObject *dic_value = [dic objectForKey:ashenTimeOut];
    if (dic_value != nil){
        timer = (int)dic_value;
    }
    UInt64 start_time = [[NSDate date] timeIntervalSince1970] * 1000;
    
    for(;;){
        UInt64 end_time = [[NSDate date] timeIntervalSince1970] * 1000;
        UInt64 time_diff = end_time - start_time;
        if (time_diff > (timer * 1000)){
            [dic setValue:@(ashenTimeOutCode) forKey:ashenCode];
            [dic setValue:ashenError forKey:ashenMessage];
            break;
        }

        if ([AshenConst sharedConst].test_done){
            
            [dic setValue:@(time_diff) forKey:@"time_diff(ms)"];
            if ([dic objectForKey:ashenCode] == nil){
                [dic setValue:@(ashenSuccessCode) forKey:ashenCode];
            }
            break;
        }
    }

    [AshenConst sharedConst].test_done = false;

    return dic;
}

+(id)decodeParamDic:(NSDictionary *)paramDic paramType:(NSString *)paramType paramName:(NSString *)paramName{
//    if ([paramType isEqual:@""]){
//        User * user = xxx
//        return user;
//    }else{
        Class ModelClass = NSClassFromString(paramType);
        return [ModelClass yy_modelWithJSON:paramDic];
//    }
}

+(NSMutableArray *)decodeParamArr:(NSArray *)paramArr paramType:(NSString *)paramType paramName:(NSString *)paramName{
    NSMutableArray * sendParamList = [NSMutableArray new];

//    if([paramType isEqual:@"NSArray<User*>"]){
//        for (int paramIndex = 0;paramIndex < paramArr.count;paramIndex ++){
//            Uesr * user = xxx;
//            [sendParamList addObject:user];
//        }
//    }else{
        for (int paramIndex = 0;paramIndex < paramArr.count;paramIndex ++){
            if ([[paramArr objectAtIndex:paramIndex] isKindOfClass:[NSDictionary class]]){
                Class ModelClass = NSClassFromString(paramType);
                [sendParamList addObject:[ModelClass yy_modelWithJSON:[paramArr objectAtIndex:paramIndex]]];
            }else{
                [sendParamList addObject:[paramArr objectAtIndex:paramIndex]];
            }
        }
//    }
    return sendParamList;
}
@end
