//
//  APISession.m
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "APISession.h"
#import "CoreDataManager.h"
#import "Category+CoreDataClass.h"
#import "AFNetworking.h"
#import "Article+CoreDataClass.h"
#import "NSDictionary+OptionalObjectForKey.h"

@implementation APISession

#pragma mark - Cateogry JSON

/*
 @param data - The JSON Data to be parsed, of type Dictionary
 @param completion - A completion block to signal that the function has completed
 @brief - Iterates through JSON data, adds the correct data to a Category entity in Core Data. Ensures duplicates are not added to CoreData using a predicate
          This predicate compares the id from the JSON with the core data id to see if it already exists, if it doesnt create a new MOC and save
          Uses a hash on the category name to ensure we get unique values at end point
 */
+(void)parseCategoryJSONData:(NSDictionary *)data withCompletion:(void (^ __nullable)(void))completion {
    NSError *jsonError = nil;

    NSPersistentContainer *container = [[CoreDataManager sharedManager] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
        if(!jsonError){
            NSArray *sourcesArray = [data objectForKey:@"sources"];
            for(NSDictionary *sourcesDict in sourcesArray){
                NSFetchRequest *fetchRequest = [Category fetchRequest];
                
                NSString *categoryName = [sourcesDict optionalObjectForKey:@"category" defaultValue:[NSNull null]];
                NSUInteger categoryUUID = [[categoryName lowercaseString] hash];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %lu", categoryUUID];
                [fetchRequest setPredicate:predicate];
                
                NSError  *error;

                NSArray *items = [context executeFetchRequest:fetchRequest error:&error];

                if(![items firstObject]){
                    Category *newCategory = [[Category alloc] initWithContext:context];
                    newCategory.category = categoryName;
                    newCategory.uuid = [NSString stringWithFormat:@"%lu", categoryUUID];
                    NSLog(@"%@", [NSString stringWithFormat:@"%@ and %@", newCategory.uuid, newCategory.category]);
                    
                    NSError *contextError = nil;
                    if(![context save:&contextError]){
                        NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
                    }
                }
            }
        } else {
            NSLog(@"JSON Error: %@", [jsonError debugDescription]);
        }
        completion();
    }];
}

/*
 @param completion - A completion block to signal that the function has completed
 @brief - Uses AFNetworking to set up a data task for the given URL
 */
+(void)createCategoryJSONDataSession:(void (^ __nullable)(void))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];

    NSURL *URL = [NSURL URLWithString:@"https://newsapi.org/v2/sources?apiKey=6ae541e0e9c94ceb9fde0b71b86d7eef"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];

    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else if (responseObject){
            [APISession parseCategoryJSONData:responseObject withCompletion:^{
                completion();
            }];
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}

#pragma mark - Top Headlines Data Session

/*
 @param completion - A completion block to signal that the function has completed
 @brief - Uses AFNetworking to set up a data task for the given URL
 */
+(void)createTopHeadlinesJSONDataSession:(void (^ __nullable)(void))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"https://newsapi.org/v2/top-headlines?language=en&country=gb&apiKey=6ae541e0e9c94ceb9fde0b71b86d7eef"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else if (responseObject){
            [APISession parseArticlesJSONData:responseObject withCompletion:completion];
        } else {
            NSLog(@"%@ %@", response, responseObject);
        }
    }];
    [dataTask resume];
}

#pragma mark - Article Core Data

/*
 @param data - The JSON Data to be parsed, of type Dictionary
 @param completion - A completion block to signal that the function has completed
 @brief - Iterates through JSON data, adds the correct data to a Category entity in Core Data. Ensures duplicates are not added to CoreData using a predicate
 This predicate compares the id from the JSON with the core data id to see if it already exists, if it doesnt create a new MOC and save
 Uses a hash on the article id string to ensure we get unique values at end point
 */
+(void)parseArticlesJSONData:(NSDictionary *)data withCompletion:(void (^ __nullable)(void))completion {
    NSError *jsonError = nil;
    
    NSPersistentContainer *container = [[CoreDataManager sharedManager] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
        if(!jsonError){
            NSArray *articlesArray = [data objectForKey:@"articles"];
            for(NSDictionary *articleDict in articlesArray){
                NSFetchRequest *fetchRequest = [Article fetchRequest];
                
                //id and name
                NSDictionary *sourceDict = [articleDict objectForKey:@"source"];
                
                //id is a string
                //NSString *articleID = [sourceDict objectForKey:@"id"];
                //NSUInteger articleUUID = [[articleID lowercaseString]hash];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", [sourceDict objectForKey:@"id"]];
                [fetchRequest setPredicate:predicate];
                
                NSError  *error;
                
                NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
                NSLog(@"HERE");
                if(![items firstObject]){
                    Article *newArticle = [[Article alloc] initWithContext:context];
                    newArticle.uuid = [sourceDict objectForKey:@"id"];
                    newArticle.name = [sourceDict optionalObjectForKey:@"name" defaultValue:nil];
                    newArticle.author = [articleDict optionalObjectForKey:@"author" defaultValue:nil];
                    newArticle.title = [articleDict optionalObjectForKey:@"title" defaultValue:nil];
                    newArticle.desc = [articleDict optionalObjectForKey:@"desc" defaultValue:nil];
                    newArticle.url = [articleDict optionalObjectForKey:@"url"defaultValue:nil];
                    newArticle.urltoimage = [articleDict optionalObjectForKey:@"urlToImage" defaultValue:nil];
                    newArticle.publishedate = [articleDict optionalObjectForKey:@"publishedAt" defaultValue:nil];
                    NSLog(@"%@ %@ %@ %@", newArticle.name, newArticle.author,  newArticle.title, newArticle.desc);
                    NSError *contextError = nil;
                    if(![context save:&contextError]){
                        NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
                    }
                }
            }
        } else {
            NSLog(@"JSON Error: %@", [jsonError debugDescription]);
        }
        if (completion) {
            completion();
        }
    }];
}

@end
