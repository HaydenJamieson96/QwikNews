//
//  CategoriesViewController.m
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "CategoriesViewController.h"
#import "CoreDataManager.h"
#import "APISession.h"
#import "Category+CoreDataClass.h"
#import "CategoryCollectionViewCell.h"

@interface CategoriesViewController ()

@property (strong, nonatomic) CoreDataManager *manager;
@property (strong, nonatomic) APISession *session;
@property (strong, nonatomic) NSMutableArray *collectionViewData;

@end

static NSString *categoryCellID = @"CategoryCell";

@implementation CategoriesViewController

/*
 Left to DO:
 Configure cell with data
 Delete cell stuff
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionViewData = [NSMutableArray array];
    self.manager = [CoreDataManager sharedManager];
    [self.session createCategoryJSONDataSession];
    [self fetchCoreData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Fetch CoreData

-(void)fetchCoreData {
    NSFetchRequest *fetchRequest = [Category fetchRequest];
    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
    fetchRequest.sortDescriptors = @[categorySort];
    
    NSError *fetchError = nil;
    self.collectionViewData = [[[[[CoreDataManager sharedManager] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&fetchError] mutableCopy];
    
    if (fetchError) {
        NSLog(@"Error fetching data %@", [fetchError localizedDescription]);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.collectionViewData count];
}

-(void)configureCell:(CategoryCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    Category *newCategory = [self.collectionViewData objectAtIndex:indexPath.row];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.categoryLabel setText:newCategory.category.capitalizedString];
        
//        CALayer* layer = cell.layer;
//        
//        [layer setCornerRadius:4.0f];
//        [layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1].CGColor];
//        [layer setBorderWidth:1.0f];
        
        cell.contentView.layer.cornerRadius = cell.frame.size.width / 2;
       // cell.contentView.layer.cornerRadius = 10.0f;
        cell.contentView.layer.borderWidth = 3.0f;
        cell.contentView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.contentView.layer.masksToBounds = YES;
        
        cell.layer.shadowColor = [UIColor lightGrayColor].CGColor;
        cell.layer.shadowOffset = CGSizeMake(0, 2.0f);
        cell.layer.shadowRadius = 2.0f;
        cell.layer.shadowOpacity = 1.0f;
        cell.layer.masksToBounds = NO;
        cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
    });
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:categoryCellID forIndexPath:indexPath];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}


@end
