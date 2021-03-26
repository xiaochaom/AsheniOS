//
//  Const.h
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString* _Nullable const ashenCode = @"code";
static NSString* _Nullable const ashenTimeOut = @"time_out";

static NSString* _Nullable const ashenSuccess = @"success";
static NSString* _Nullable const ashenError = @"error";
static NSString* _Nullable const ashenErrorMessage = @"errorMessage";
static NSString* _Nullable const ashenMessage = @"message"; // 获取接口返回值
static NSString* _Nullable const ashenTestClassName = @"testClassName";
static NSString* _Nullable const ashenTestParamArr = @"paramArr";

static int const ashenSuccessCode = 200;
static int const ashenErrorCode = 203; // SDK 接口返回失败
static int const ashenTimeOutCode = 300;
static int const ashenExcptionCode = 500; // demo 运行发生异常
static int const ashenTimeOutNum = 10;

NS_ASSUME_NONNULL_BEGIN

@interface AshenConst : NSObject
@property (strong, nonatomic) NSDictionary *ashenInterfaceDic;
@property (strong, nonatomic) NSDictionary *ashenClassDic;
@property (strong, nonatomic) NSMutableDictionary *ashenResponseDic;
@property (nonatomic,readwrite) BOOL test_done;
+ (instancetype)sharedConst;
@end

NS_ASSUME_NONNULL_END
