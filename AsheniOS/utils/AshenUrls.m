//
//  AshenUrls.m
//  AsheniOS
//
//  Created by 李亚超 on 2021/3/18.
//

#import "AshenUrls.h"
#import <GCDWebServerURLEncodedFormRequest.h>
#import <GCDWebServerDataResponse.h>

#import <objc/runtime.h>
#import <YYModel/YYModel.h>
#import "AshenConst.h"
#import "AshenUtil.h"
#import "AshenCallBack.h"
#import "AshenOrderDictionary.h"

@interface RCMessageMapper : NSObject
+ (instancetype)sharedMapper;
@property (nonatomic, strong) NSMutableDictionary *messageTypeIdentifierMapping;
@end

@implementation AshenUrls

- (void) webServerUpdateUrls:(GCDWebUploader *)webServer {
    [webServer addHandlerForMethod:@"POST" pathRegex:@"^/" requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
        return [self interfaceTest:(GCDWebServerURLEncodedFormRequest*)request];
    }];
    [webServer addHandlerForMethod:@"GET" path:@"/getInterfaceParams" requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
        return [self getInterfaceParams:(GCDWebServerURLEncodedFormRequest*)request];
    }];
    [webServer addHandlerForMethod:@"GET" path:@"/getAllInterface" requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse*(GCDWebServerRequest* request) {
        return [self getAllInterface:(GCDWebServerURLEncodedFormRequest*)request];
    }];
    
    
}

- (GCDWebServerResponse*)getInterfaceParams:(GCDWebServerURLEncodedFormRequest*)request{
    NSDictionary * request_dic = request.query;
    NSMutableDictionary * classDic = [NSMutableDictionary new];
    if ([[request_dic allKeys]containsObject:@"name"]){
        for (NSString * className in [[AshenUtil shareUtil].ashenInterfaceDic allKeys]){
            NSMutableArray * methodArr = [NSMutableArray new];
            for (int methodIndex = 0; methodIndex < [[AshenUtil shareUtil].ashenInterfaceDic[className] count];methodIndex ++){
                NSDictionary * methodDic = [[AshenUtil shareUtil].ashenInterfaceDic[className] objectAtIndex:methodIndex];
                if ([[methodDic valueForKey:@"interface_name"] rangeOfString:[request_dic valueForKey:@"name"]].location != NSNotFound){
                    [methodArr addObject:methodDic];
                }
            }
            if (methodArr.count > 0){
                [classDic setValue:methodArr forKey:className];
            }
        }
    }
    return [GCDWebServerDataResponse responseWithJSONObject:classDic];
}

- (GCDWebServerResponse*)getAllInterface:(GCDWebServerURLEncodedFormRequest*)request{
    
    return [GCDWebServerDataResponse responseWithJSONObject:[AshenUtil shareUtil].ashenInterfaceDic];
}

- (GCDWebServerResponse*)interfaceTest:(GCDWebServerURLEncodedFormRequest*)request {

    
    [AshenConst sharedConst].ashenResponseDic = [NSMutableDictionary new];
    [AshenConst sharedConst].test_done = NO;
    NSString *requestData = [[NSString alloc] initWithData:request.data encoding:NSUTF8StringEncoding];
    NSDictionary* requestDic;
    if (![requestData isEqual:@""]){
        requestDic = [AshenUtil dictionaryWithJsonString:requestData];
    }else if ([[request.query allKeys] count] > 0){
        requestDic = request.query;
    }else{
        requestDic = nil;
    }
 
    
    NSDictionary* interfaceDic = [AshenConst sharedConst].ashenInterfaceDic;
    
    NSString* className;
    if (requestDic != nil){
        if ([[requestDic allKeys] containsObject:ashenTestClassName]){
            className = [requestDic valueForKey:ashenTestClassName];
        }
    }
    
    // 开始遍历 class 的字典
    for (NSString* keyIndex in [interfaceDic allKeys]){
        if (className != nil && ![className isEqual:keyIndex]){
            continue;
        }
        NSArray* methodArr = [interfaceDic valueForKey:keyIndex];
        // 遍历函数
        for (int methodIndex = 0; methodIndex < [methodArr count];methodIndex ++){
            NSDictionary* methodDic = [methodArr objectAtIndex:methodIndex];
            NSArray* currentParamTypeList = [methodDic valueForKey:@"param_type_list"];
            NSString* interfaceName = [methodDic valueForKey:@"interface_name"];
            NSString* returnType = [methodDic valueForKey:@"return_type"];
            NSArray* currentParamList = [methodDic valueForKey:@"param_list"];
//            NSMutableArray* requestParamList;
            NSMutableArray * sendParamList = [NSMutableArray new];
            bool blockInParam = NO;
            if([interfaceName isEqual:request.path]){
                // 定义一个用于传递参数的 list
                if (requestDic != nil){
                    for (int _paramIndex = 0; _paramIndex < currentParamList.count; _paramIndex ++){
                        NSString * currentParamName = [currentParamList objectAtIndex:_paramIndex];
                        NSString * currentParamTypeName = [currentParamTypeList objectAtIndex:_paramIndex];
                        
                        if ([currentParamTypeName hasPrefix:@"block_"]){
                            // 如果是block
                            blockInParam = YES;
                            if ([[[[AshenCallBack sharedAshenCallBack]callBackDic] allKeys]containsObject:currentParamTypeName]){
                                if ([[AshenCallBack sharedAshenCallBack].lastCallBackNameArray containsObject:currentParamName]){
                                    [sendParamList addObject:[[[AshenCallBack sharedAshenCallBack]callBackDic] valueForKey:currentParamTypeName]];
                                }else{
                                    [sendParamList addObject:[[[AshenCallBack sharedAshenCallBack]noReturnCallBackDic] valueForKey:currentParamTypeName]];
                                }
                            }else{
                                return [GCDWebServerDataResponse responseWithJSONObject:@{ashenCode:@(ashenErrorCode),ashenMessage:[@"未匹配到 %@" stringByAppendingString:currentParamTypeName]}];
                            }
                        }else{
                            if (![[requestDic allKeys]containsObject:currentParamName]){
                                return [GCDWebServerDataResponse responseWithJSONObject:@{ashenCode:@(ashenErrorCode),ashenMessage:[@"入参未收到参数: %@" stringByAppendingString:currentParamTypeName]}];;
                            }
                            // 如果是字典
                            if ([requestDic[currentParamName] isKindOfClass:[NSDictionary class]]){
                                id currentParam = [AshenUtil decodeParamDic:requestDic[currentParamName]
                                                                  paramType:currentParamTypeName
                                                                  paramName:currentParamName];

                                [sendParamList addObject:currentParam];
                            }else if([requestDic[currentParamName] isKindOfClass:[NSArray class]]){
                                // 如果是数组
                                NSArray* currentArr = [AshenUtil decodeParamArr:requestDic[currentParamName]
                                                                      paramType:currentParamTypeName
                                                                      paramName:currentParamName];
                                [sendParamList addObject:currentArr];
                                
                            }else{
                                [sendParamList addObject:requestDic[currentParamName]];
                            }
                        }
                    }
                }

                NSLog(@"methodName = %@",@"开始测试");
                // 拼参数列表
                // 获取参数列表
                
                SEL sel =  NSSelectorFromString([interfaceName stringByReplacingOccurrencesOfString:@"/"withString:@""]);
                if (![[[[AshenConst sharedConst]ashenClassDic]allKeys]containsObject:keyIndex]){
                    NSMutableDictionary* errorDic = [NSMutableDictionary new];
                    [errorDic setValue:[@"未找到 class: " stringByAppendingString:keyIndex] forKey:ashenCode];
                    [errorDic setValue:@(ashenErrorCode) forKey:ashenMessage];
                    return [GCDWebServerDataResponse responseWithJSONObject:errorDic];
                }
                id classInstance = [[[AshenConst sharedConst]ashenClassDic] valueForKey:keyIndex];
                NSMethodSignature *signature = [classInstance methodSignatureForSelector:sel];
                NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
                invocation.target = classInstance;
                invocation.selector = sel;
                for (int index = 0; index < [sendParamList count];index ++){
                    int tmpIndex = index + 2;
                    id tmpObj = sendParamList[index];
                
                    if([tmpObj isKindOfClass:[NSNumber class]]) {
                        NSString* tmpStr = [NSString stringWithFormat:@"%@",tmpObj];
                        //字条串是否包含有某字符串
                        if ([tmpStr rangeOfString:@"."].location == NSNotFound) {
                            long tmpLong = ((NSNumber*)tmpObj).longValue;
                            [invocation setArgument:&tmpLong atIndex:tmpIndex];
                        } else {
                            double tmpLong = ((NSNumber*)tmpObj).doubleValue;
                            [invocation setArgument:&tmpLong atIndex:tmpIndex];
                        }
                    }else{
                        [invocation setArgument:&tmpObj atIndex:tmpIndex];
                    }
                }
                [invocation invoke];
                if (![returnType isEqual:@"void"] && !blockInParam){
                    __autoreleasing id rep = nil;
                    [invocation getReturnValue:&rep];
                    NSDictionary *json = [rep yy_modelToJSONObject];
                    [[AshenConst sharedConst].ashenResponseDic setValue:json  forKey:ashenMessage];
                    [AshenConst sharedConst].test_done = YES;
                }
                
                NSDictionary* json_str = [AshenUtil get_response:[AshenConst sharedConst].ashenResponseDic];
                return [GCDWebServerDataResponse responseWithJSONObject:json_str];
            }
        }
    }
    NSMutableDictionary* errorDic = [NSMutableDictionary new];
    [errorDic setValue:@"未找到匹配的接口" forKey:ashenCode];
    [errorDic setValue:@(ashenErrorCode) forKey:ashenMessage];
    
    return [GCDWebServerDataResponse responseWithJSONObject:errorDic];
}
@end
