//
//  APISession.h
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APISession : NSObject

+(void)parseCategoryJSONData:(NSDictionary *_Nonnull)data withCompletion:(void (^ __nullable)(void))completion;

+(void)createCategoryJSONDataSession:(void (^ __nullable)(void))completion;

+(void)createTopHeadlinesJSONDataSession:(void (^ __nullable)(void))completion;

+(void)parseArticlesJSONData:(NSDictionary *_Nonnull)data withCompletion:(void (^ __nullable)(void))completion;

+(void)createArticlesJSONDataSession:(NSString *_Nullable)category withCompletionBlock:(void (^ __nullable)(void))completion;

@end
