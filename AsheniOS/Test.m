//
//  Test.m
//  AsheniOS
//
//  Created by 李亚超 on 2021/3/26.
//

#import "Test.h"

@implementation Test

-(NSMutableDictionary *)getUser:(NSString *)name age:(int)age{
    NSMutableDictionary * user = [NSMutableDictionary new];
    [user setValue:name forKey:@"name"];
    [user setValue:@(age) forKey:@"age"];
    return user;
}
@end
