//
//  NSDictionary+OptionalObjectForKey.h
//  QwikNews
//
//  Created by TheAppExperts on 11/30/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (OptionalObjectForKey)

- (id)optionalObjectForKey:(id)key;
- (id)optionalObjectForKey:(id)key defaultValue:(id)defaultValue;

@end
