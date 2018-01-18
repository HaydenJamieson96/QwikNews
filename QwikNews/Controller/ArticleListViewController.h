//
//  ArticleListViewController.h
//  QwikNews
//
//  Created by Hayden Jamieson on 11/29/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categ+CoreDataClass.h"

@interface ArticleListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Categ *selectedCategory;

@end
