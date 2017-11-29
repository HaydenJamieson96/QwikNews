//
//  TopHeadlinesViewController.h
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface TopHeadlinesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
