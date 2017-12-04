//
//  ArticleListViewController.h
//  QwikNews
//
//  Created by TheAppExperts on 11/29/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category+CoreDataClass.h"

@interface ArticleListViewController : UIViewController

@property (strong, nonatomic) Category *selectedCategory;

@end
