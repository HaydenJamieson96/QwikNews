//
//  ArticleInfoViewController.h
//  QwikNews
//
//  Created by Hayden Jamieson on 12/1/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Article+CoreDataClass.h"

@interface ArticleInfoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishedAtLabel;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
