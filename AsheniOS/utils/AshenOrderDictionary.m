//
//  AshenOrderDictionary.m
//  AsheniOS
//
//  Created by 李亚超 on 2021/3/22.
//

#import "AshenOrderDictionary.h"



@implementation AshenOrderDictionary {
    NSMutableArray *_values;
    NSMutableOrderedSet *_keys;
}

- (instancetype)init {
    if (self = [super init]) {
        _values = NSMutableArray.new;
        _keys = NSMutableOrderedSet.new;
    }
    return self;
}

- (NSUInteger)count {
    return _keys.count;
}

- (NSEnumerator *)keyEnumerator {
    return _keys.objectEnumerator;
}

- (id)objectForKey:(NSString *)key {
    NSUInteger index = [_keys indexOfObject:key];
    if (index != NSNotFound) {
        return _values[index];
    }
    return nil;
}

- (void)setObject:object forKey:(NSString *)key {
    if (!object) {
        return;
    }
    NSUInteger index = [_keys indexOfObject:key];
    if (index != NSNotFound) {
        _values[index] = object;
    } else {
        [_keys addObject:key];
        [_values addObject:object];
    }
}

@end


