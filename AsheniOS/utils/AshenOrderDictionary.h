//
//  AshenOrderDictionary.h
//  AsheniOS
//
//  Created by 李亚超 on 2021/3/22.
//

#import <Foundation/Foundation.h>

@interface AshenOrderDictionary : NSMutableDictionary
- (id)objectForKey:(NSString *)key;
- (void)setObject:object forKey:(NSString *)key;
@end

