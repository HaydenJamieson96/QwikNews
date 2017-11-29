//
//  TopHeadlinesViewController.m
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "TopHeadlinesViewController.h"
#import <ChameleonFramework/Chameleon.h>

@interface TopHeadlinesViewController ()

@end

static NSString *topHeadlinesCellID = @"TopHeadlinesCell";

@implementation TopHeadlinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCell * cell = [self.tableView dequeueReusableCellWithIdentifier:topHeadlinesCellID];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:topHeadlinesCellID];
    }
    [self configureCell:cell forIndexPath:indexPath];
    //configure right buttons
    //    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor flatRedColor]],
    //                          [MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor flatGrayColor]]];
    //    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Check" icon:[UIImage imageNamed:@"check.png"] backgroundColor:[UIColor flatGreenColor]],
    //                         [MGSwipeButton buttonWithTitle:@"Fav" icon:[UIImage imageNamed:@"fav.png"] backgroundColor:[UIColor flatBlueColor]]];
    return cell;
}

-(void)configureCell:(MGSwipeTableCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    //Configure what I want the cell to look like now
    cell.textLabel.text = @"Title";
    cell.detailTextLabel.text = @"Detail text";
    //cell.delegate = self; //optional
    
    //configure left buttons
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Check" backgroundColor:[UIColor flatGreenColor] callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"Convenience callback for check buttons!");
        return YES;
    }],[MGSwipeButton buttonWithTitle:@"Fav" backgroundColor:[UIColor flatBlueColor] callback:^BOOL(MGSwipeTableCell *sender) {
        return YES;
    }]];
    cell.leftExpansion.buttonIndex = 0;
    cell.rightExpansion.threshold = 2.0;
    cell.leftExpansion.fillOnTrigger = YES;
    cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
    
    //Configure right buttons
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor flatRedColor] callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"Convenience callback for Delete button!");
        return YES;
    }],[MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor flatGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
        return YES;
    }]];
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.threshold = 2.0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    
    cell.layer.cornerRadius = 20;
    cell.layer.masksToBounds = YES;
}

@end
