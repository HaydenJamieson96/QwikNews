//
//  CoreDataManager.h
//  QwikNews
//
//  Created by Hayden Jamieson on 11/27/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Article+CoreDataClass.h"
#import "Categ+CoreDataClass.h"

@interface CoreDataManager : NSObject

+(instancetype)sharedManager;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@property (strong, nonatomic) Article *selectedArticle;

@property (strong, nonatomic) Categ *selectedCategory;

@property (strong, nonatomic) NSString *storedSpeech;

@end
