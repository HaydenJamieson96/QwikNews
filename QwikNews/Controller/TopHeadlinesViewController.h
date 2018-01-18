//
//  TopHeadlinesViewController.h
//  QwikNews
//
//  Created by Hayden Jamieson on 11/27/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface TopHeadlinesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
