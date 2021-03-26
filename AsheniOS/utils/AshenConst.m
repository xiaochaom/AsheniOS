//
//  Const.m
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import "AshenConst.h"
#import "AshenUtil.h"
#import "Test.h"
@implementation AshenConst
+ (instancetype)sharedConst{
    static AshenConst *ashenConst = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ashenConst = [[AshenConst alloc] init];
        ashenConst.ashenInterfaceDic = [AshenUtil getJsonFileToDic:@"AshenClass.json"];
        // 初始化类对象和类字符串的字典
        //ashenConst.ashenClassDic = @{@"xxxx.h":[xxx instance]};
        ashenConst.ashenClassDic = @{@"Test.h":[Test new]};
        ashenConst.ashenResponseDic = [NSMutableDictionary new];
        ashenConst.test_done = NO;
    });
    return ashenConst;
}


@end
