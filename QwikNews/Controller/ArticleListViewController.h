//
//  ArticleListViewController.h
//  QwikNews
//
//  Created by TheAppExperts on 11/29/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categ+CoreDataClass.h"

@interface ArticleListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Categ *selectedCategory;

@end
