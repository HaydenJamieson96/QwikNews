//
//  ArticleListViewController.m
//  QwikNews
//
//  Created by TheAppExperts on 11/29/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "ArticleListViewController.h"
#import "CoreDataManager.h"
#import "APISession.h"

@interface ArticleListViewController ()
@property (strong, nonatomic) CoreDataManager *manager;
@property (strong, nonatomic) APISession *session;

@end

@implementation ArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.manager = [CoreDataManager sharedManager];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
   
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
