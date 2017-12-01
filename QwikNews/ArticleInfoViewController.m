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

@interface ArticleInfoViewController ()
@property (strong, nonatomic) CoreDataManager *manager;

@end

@implementation ArticleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [CoreDataManager sharedManager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    [self configurePageInfoWithArticle:self.manager.selectedArticle];
}

-(void)configurePageInfoWithArticle:(Article *)article {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:article.urltoimage]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

    self.nameLabel.text = article.name;
    self.authorLabel.text = article.author;
    self.titleLabel.text = article.title;
    self.descriptionLabel.text = article.desc;
    self.urlLabel.text = article.url;
    self.publishedAtLabel.text = [NSString stringWithFormat:@"Published at: %@", article.publishedate];
}

@end
