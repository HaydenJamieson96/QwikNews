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

@implementation APISession

#pragma mark - Cateogry JSON

-(void)parseCategoryJSONData:(NSData *)data {
    NSError *jsonError = nil;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
    
    NSPersistentContainer *container = [[CoreDataManager sharedManager] persistentContainer];
    [container performBackgroundTask:^(NSManagedObjectContext * _Nonnull context) {
        if(!jsonError){
            NSArray *sourcesArray = [root objectForKey:@"sources"];
            for(NSDictionary *sourcesDict in sourcesArray){
                Category *newCategory = [[Category alloc] initWithContext:[[[CoreDataManager sharedManager] persistentContainer] viewContext]];
                newCategory.identifier = [sourcesDict valueForKeyPath:@"id"];
                newCategory.category = [sourcesDict valueForKeyPath:@"category"];
                NSLog(@"%@", [NSString stringWithFormat:@"%@ and %@", newCategory.identifier, newCategory.category]);
                [[CoreDataManager sharedManager] saveContext];
            }
            
            NSError *contextError = nil;
            if(![context save:&contextError]){
                NSLog(@"Failure to save context %@\n%@", [contextError localizedDescription], [contextError userInfo]);
            }
        } else {
            NSLog(@"JSON Error: %@", [jsonError debugDescription]);
        }
    }];
}

-(void)createCategoryJSONDataSession {
    NSMutableString *urlString = [NSMutableString stringWithString:@"https://newsapi.org/v2/sources?apiKey=6ae541e0e9c94ceb9fde0b71b86d7eef"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionTask *dataTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Error: %@", [error localizedDescription]);
        } else if (data){
            [self parseCategoryJSONData:data];
        } else {
            NSLog(@"Something wnet wrong");
        }
    }];
    [dataTask resume];
}

#pragma mark - Article JSON

@end
