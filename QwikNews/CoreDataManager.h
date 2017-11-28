//
//  CoreDataManager.h
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataManager : NSObject

+(instancetype)sharedManager;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@end
