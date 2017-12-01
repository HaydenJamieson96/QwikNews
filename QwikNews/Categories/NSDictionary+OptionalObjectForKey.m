//
//  NSDictionary+OptionalObjectForKey.m
//  QwikNews
//
//  Created by TheAppExperts on 11/30/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "NSDictionary+OptionalObjectForKey.h"

@implementation NSDictionary (OptionalObjectForKey)

- (id)optionalObjectForKey:(id)key {
    return [self optionalObjectForKey:key defaultValue:[NSNull null]];
}
- (id)optionalObjectForKey:(id)key defaultValue:(id)defaultValue {
    id obj = [self objectForKey:key];
    return (obj == [NSNull null] || !obj) ? defaultValue : obj;
}

@end
