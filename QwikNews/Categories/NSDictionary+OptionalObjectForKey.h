//
//  NSDictionary+OptionalObjectForKey.h
//  QwikNews
//
//  Created by Hayden Jamieson on 11/30/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (OptionalObjectForKey)

- (id)optionalObjectForKey:(id)key;
- (id)optionalObjectForKey:(id)key defaultValue:(id)defaultValue;

@end
