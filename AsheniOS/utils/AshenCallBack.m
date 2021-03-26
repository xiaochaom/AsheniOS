//
//  CallBack.m
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import "AshenCallBack.h"
#import "AshenConst.h"

@implementation AshenCallBack
+ (instancetype)sharedAshenCallBack{
    static AshenCallBack *ashenCallBack = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ashenCallBack = [[AshenCallBack alloc] init];
        ashenCallBack.callBackDic = [NSMutableDictionary new];
        ashenCallBack.noReturnCallBackDic = [NSMutableDictionary new];
        [ashenCallBack setBlock:ashenCallBack.callBackDic];
        [ashenCallBack setNoReturnBlock:ashenCallBack.noReturnCallBackDic];
        // 包含这些参数名的 block 会被认为是结束状态
        ashenCallBack.lastCallBackNameArray = [[NSMutableArray alloc]initWithObjects:@"successBlock",@"errorBlock",@"cancelBlock", nil];
    });
    return ashenCallBack;
}

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
@end
