//
//  Util.h
//  iOS
//
//  Created by 李亚超 on 2021/3/18.
//  Copyright © 2021 李亚超. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AshenUtil : NSObject
@property (strong, nonatomic) NSDictionary *ashenInterfaceDic;
+ (instancetype)shareUtil;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
+ (NSDictionary *)getJsonFileToDic:(NSString *)jsonname;
+(NSDictionary *)get_response:(NSDictionary *)dic;
+ (NSDictionary *)dictionarySort:(NSDictionary *)oldDic sortArr:(NSArray *)sortArr;
+(id)decodeParamDic:(NSDictionary *)paramDic
          paramType:(NSString *)paramType
          paramName:(NSString *)paramName;
+(NSMutableArray *)decodeParamArr:(NSArray *)paramArr
                        paramType:(NSString *)paramType
                        paramName:(NSString *)paramName;
@end

NS_ASSUME_NONNULL_END
