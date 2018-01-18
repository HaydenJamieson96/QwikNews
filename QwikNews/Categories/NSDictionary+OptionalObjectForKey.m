//
//  NSDictionary+OptionalObjectForKey.m
//  QwikNews
//
//  Created by Hayden Jamieson on 11/30/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
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
