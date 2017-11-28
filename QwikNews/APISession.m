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

@implementation APISession

#pragma mark - Cateogry JSON

/*
 @param data - The JSON Data to be parsed, of type Dictionary
 @param completion - A completion block to signal that the function has completed
 @brief - Iterates through JSON data, adds the correct data to a Category entity in Core Data
 */
+(void)parseCategoryJSONData:(NSDictionary *)data withCompletion:(void (^ __nullable)(void))completion {
    NSError *jsonError = nil;

    NSPersistentContainer *container = [[CoreDataManager sharedManager] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
        if(!jsonError){
            NSArray *sourcesArray = [data objectForKey:@"sources"];
            for(NSDictionary *sourcesDict in sourcesArray){
                NSFetchRequest *fetchRequest = [Category fetchRequest];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier == %@", [sourcesDict objectForKey:@"id"]];
                [fetchRequest setPredicate:predicate];
                
                NSError  *error;
                NSArray *items = [[[[CoreDataManager sharedManager] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&error];

                if(![items firstObject]){
                    Category *newCategory = [[Category alloc] initWithContext:[[[CoreDataManager sharedManager] persistentContainer] viewContext]];
                    newCategory.identifier = [sourcesDict objectForKey:@"id"];
                    newCategory.category = [sourcesDict objectForKey:@"category"];
                    NSLog(@"%@", [NSString stringWithFormat:@"%@ and %@", newCategory.identifier, newCategory.category]);
                    [[CoreDataManager sharedManager] saveContext];
                }
            }
            
            completion();
            NSError *contextError = nil;
            if(![context save:&contextError]){
                NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
            }
        } else {
            NSLog(@"JSON Error: %@", [jsonError debugDescription]);
        }
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

#pragma mark - Article JSON

@end
