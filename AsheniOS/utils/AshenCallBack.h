//
//  CallBack.h
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AshenCallBack : NSObject
+ (instancetype)sharedAshenCallBack;
@property (strong, nonatomic) NSMutableDictionary *callBackDic;
@property (strong, nonatomic) NSMutableDictionary *noReturnCallBackDic;
@property (strong, nonatomic) NSMutableArray *lastCallBackNameArray;
-(void) setBlock:(NSMutableDictionary *)blockDic;
@end

NS_ASSUME_NONNULL_END
