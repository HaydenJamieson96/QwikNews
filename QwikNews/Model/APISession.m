//
//  APISession.m
//  QwikNews
//
//  Created by Hayden Jamieson on 11/27/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import "APISession.h"
#import "CoreDataManager.h"
#import "Categ+CoreDataClass.h"
#import "AFNetworking.h"
#import "Article+CoreDataClass.h"
#import "NSDictionary+OptionalObjectForKey.h"
#import "TopHeadlinesViewController.h"
#import "Source+CoreDataClass.h"

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
                NSFetchRequest *categFetch = [Categ fetchRequest];
                
                NSString *categoryName = [sourcesDict optionalObjectForKey:@"category" defaultValue:nil];
                NSUInteger categoryUUID = [[categoryName lowercaseString] hash];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %lu", categoryUUID];
                [categFetch setPredicate:predicate];
                
                NSError *error;
                NSArray *items = [context executeFetchRequest:categFetch error:&error];

                Categ *currentCategory = [items count] > 0 ? [items firstObject] : [[Categ alloc] initWithContext:context];
                currentCategory.name = categoryName;
                currentCategory.uuid = [NSString stringWithFormat:@"%lu", (unsigned long)categoryUUID];
                
                //Handle the source
                NSFetchRequest *sourceFetch = [Source fetchRequest];
                
                NSString *sourceName = [sourcesDict optionalObjectForKey:@"name" defaultValue:nil];
                NSUInteger sourceUUID = [[sourceName lowercaseString]hash];
                
                NSPredicate *sourcePredicate = [NSPredicate predicateWithFormat:@"uuid == %lu", sourceUUID];
                [sourceFetch setPredicate:sourcePredicate];
                
                error = nil;
                items = [context executeFetchRequest:sourceFetch error:&error];
                
                Source *currentSource = [items count] > 0 ? [items firstObject] : [[Source alloc] initWithContext:context];
                currentSource.uuid = [NSString stringWithFormat:@"%lu", (unsigned long)sourceUUID];
                currentSource.name = sourceName;
                currentSource.urlString = [sourcesDict optionalObjectForKey:@"url" defaultValue:@""];
                currentSource.desc = [sourcesDict optionalObjectForKey:@"description" defaultValue:@""];
                
                currentSource.category = currentCategory;
                
                NSError *contextError = nil;
                if(![context save:&contextError]){
                    NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
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

#pragma mark - Article by Category Data Session

/*
 @param category - The category to which the JSON will be filtered on
 @param completion - A completion block to signal that the function has completed
 @brief - Uses AFNetworking to set up a data task for the given URL
 */
+(void)createArticlesJSONDataSession:(NSString *)category withCompletionBlock:(void (^ __nullable)(void))completion {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://newsapi.org/v2/top-headlines?category=%@&language=en&apiKey=6ae541e0e9c94ceb9fde0b71b86d7eef", category]];
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
                NSString *articleID = [articleDict objectForKey:@"title"];
                NSUInteger articleUUID = [[articleID lowercaseString]hash];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %lu", articleUUID];
                [fetchRequest setPredicate:predicate];
                
                NSError  *error;
                
                NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
                
                Article *currentArticle = [items count] > 0 ? [items firstObject] : [[Article alloc] initWithContext:context];
                currentArticle.uuid = [NSString stringWithFormat:@"%lu", (unsigned long)articleUUID];
                currentArticle.author = [articleDict optionalObjectForKey:@"author" defaultValue:nil];
                currentArticle.title = [articleDict optionalObjectForKey:@"title" defaultValue:nil];
                currentArticle.desc = [articleDict optionalObjectForKey:@"description" defaultValue:nil];
                currentArticle.url = [articleDict optionalObjectForKey:@"url" defaultValue:nil];
                currentArticle.urltoimage = [articleDict optionalObjectForKey:@"urlToImage" defaultValue:nil];
                currentArticle.publishedate = [articleDict optionalObjectForKey:@"publishedAt" defaultValue:nil];
                
                NSFetchRequest *sourceFetch = [Source fetchRequest];
                
                NSString *sourceName = [sourceDict objectForKey:@"name"];
                NSPredicate *sourceNamePredicate = [NSPredicate predicateWithFormat:@"name == %@", sourceName];
                [sourceFetch setPredicate:sourceNamePredicate];
                
                error = nil;
                items = [context executeFetchRequest:sourceFetch error:&error];
                
                if([items firstObject]){
                    currentArticle.source = [items firstObject];
                }
                NSLog(@"Article: %@ %@ %@", currentArticle.author, currentArticle.title, currentArticle.desc);
                NSLog(@"Source: %@", sourceName);
                NSError *contextError = nil;
                if(![context save:&contextError]){
                    NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
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
