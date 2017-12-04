//
//  ArticleInfoViewController.m
//  QwikNews
//
//  Created by TheAppExperts on 12/1/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "ArticleInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CoreDataManager.h"
#import "SVWebViewController.h"
#import "SVWebViewControllerActivity.h"

@interface ArticleInfoViewController ()
@property (strong, nonatomic) CoreDataManager *manager;
@property (strong, nonatomic) UIBarButtonItem *shareButton;

@end

@implementation ArticleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share:)];
    self.navigationItem.rightBarButtonItem = self.shareButton;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textViewTapped:)];
    [self.urlTextView addGestureRecognizer:gestureRecognizer];
    [self.urlTextView isUserInteractionEnabled];
    self.manager = [CoreDataManager sharedManager];
}

- (void)viewDidAppear:(BOOL)animated {
    [self configurePageInfoWithArticle:self.manager.selectedArticle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom functions & SVWebViewController delegate

/*
 @brief - Configure UIActivityViewController and send article URL to action
 */
- (void)share:(id)sender {
    NSString *postText = [NSString stringWithFormat:@"Check out this article - %@", self.manager.selectedArticle.url];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[postText] applicationActivities:nil];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            activityController.popoverPresentationController.sourceView = self.view;
            activityController.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/4, 0, 0);
        }
    [activityController.view setTintColor:[UIColor blueColor]];
    [self presentViewController:activityController animated:YES completion:nil];
}

/*
 @brief - Handles tap gesture on text view - binded to urlTextView in viewDidLoad
 @param - The text view to handle
 */
-(void)textViewTapped:(UITextView *)textView {
    NSString *handleATS = [self.manager.selectedArticle.url stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    NSURL *URL = [NSURL URLWithString:handleATS];
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithURL:URL];
    [webViewController.view setTintColor:[UIColor blueColor]];
    [self.navigationController pushViewController:webViewController animated:YES];
}

/*
 @brief - Delegate method for SVWebViewController which handles the user rotating the device
 @param - THe interface orientation
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

/*
 @brief - Helper function to configure the controls of the page with Article information
 */
-(void)configurePageInfoWithArticle:(Article *)article {
    self.navigationItem.title = article.name;
    NSString *handleATS = [article.urltoimage stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:handleATS]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    self.imageView.layer.cornerRadius = 10;
    self.authorLabel.text = [NSString stringWithFormat:@"By: %@", article.author];
    self.titleLabel.text = article.title;
    self.descriptionTextView.text = article.desc;
    self.urlTextView.text = article.url;
    self.publishedAtLabel.text = [NSString stringWithFormat:@"Published at: %@", article.publishedate];
}

@end
