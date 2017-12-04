//
//  CoreDataManager.h
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Article+CoreDataClass.h"
//#import "Category+CoreDataClass.h"

@interface CoreDataManager : NSObject

+(instancetype)sharedManager;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@property (strong, nonatomic) Article *selectedArticle;

//@property (strong, nonatomic) Category *selectedCategory;

@property (strong, nonatomic) NSCache *imageCache;

@end
