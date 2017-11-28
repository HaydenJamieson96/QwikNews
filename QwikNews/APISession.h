//
//  APISession.h
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APISession : NSObject

-(void)parseCategoryJSONData:(NSData *)data;

-(void)createCategoryJSONDataSession;

@end
