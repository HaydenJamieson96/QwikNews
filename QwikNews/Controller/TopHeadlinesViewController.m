//
//  TopHeadlinesViewController.m
//  QwikNews
//
//  Created by TheAppExperts on 11/27/17.
//  Copyright © 2017 TheAppExperts. All rights reserved.
//

#import "TopHeadlinesViewController.h"
#import <ChameleonFramework/Chameleon.h>
#import "CoreDataManager.h"
#import "Article+CoreDataClass.h"
#import "APISession.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface TopHeadlinesViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CoreDataManager *manager;
@property (strong, nonatomic) APISession *session;

@end

static NSString *topHeadlinesCellID = @"TopHeadlinesCell";
static NSString *showArticleInfoSegueID = @"ShowArticleInfoSegue";

@implementation TopHeadlinesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.manager = [CoreDataManager sharedManager];
    [self.navigationController setHidesNavigationBarHairline:YES];
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *fetchError = nil;
    if(![[self fetchedResultsController]performFetch:&fetchError]){
        NSLog(@"Unresolved Error: %@, %@", fetchError, [fetchError userInfo]);
        exit(-1);
    }
    [APISession createTopHeadlinesJSONDataSession:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)contextChanged:(NSNotification *)notification
{
    NSManagedObjectContext *context = [[[CoreDataManager sharedManager] persistentContainer] viewContext];
    if ([notification object] == context) return;
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    [context mergeChangesFromContextDidSaveNotification:notification];
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSUInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (MGSwipeTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MGSwipeTableCell * cell = [self.tableView dequeueReusableCellWithIdentifier:topHeadlinesCellID];
    if (!cell) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:topHeadlinesCellID];
    }
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)deleteArticleAtIndexPath:(NSIndexPath *)indexPath {
    Article *articleToDelete = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self.manager.persistentContainer.viewContext deleteObject:articleToDelete];
    NSError *deleteError = nil;
    [[_fetchedResultsController managedObjectContext] save:&deleteError];
    if(deleteError)
        NSLog(@"Unresolved Error: %@, %@", deleteError, [deleteError userInfo]);
}

-(void)swipeSelectArticleAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:showArticleInfoSegueID sender:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self swipeSelectArticleAtIndexPath:indexPath];
}

-(void)configureCell:(MGSwipeTableCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSString *handleATS = [article.urltoimage stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:handleATS]
                      placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    cell.imageView.clipsToBounds = YES;
    [cell.textLabel setTextColor:[UIColor flatGreenColorDark]];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:20.0];
    cell.textLabel.text = article.author;
    cell.detailTextLabel.text = article.title;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Avenir" size:16.0];
    
    [self configureSwipeButtons:cell forIndexPath:indexPath];
    
    //cell.layer.borderColor = [UIColor flatGreenColorDark].CGColor;
    //cell.layer.borderWidth = 1.0f;
    cell.layer.cornerRadius = 20;
    cell.layer.masksToBounds = YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)configureSwipeButtons:(MGSwipeTableCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.leftButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"checked.png"] backgroundColor:[UIColor flatGreenColorDark] callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"Convenience callback for check buttons!");
        [self swipeSelectArticleAtIndexPath:indexPath];
        return YES;
    }],[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"heart.png"] backgroundColor:[UIColor flatBlueColor] callback:^BOOL(MGSwipeTableCell *sender) {
        return YES;
    }]];
    cell.leftExpansion.buttonIndex = 0;
    cell.rightExpansion.threshold = 2.0;
    cell.leftExpansion.fillOnTrigger = YES;
    cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
    
    cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"delete.png"] backgroundColor:[UIColor flatRedColor] callback:^BOOL(MGSwipeTableCell *sender) {
        NSLog(@"Convenience callback for Delete button!");
        [self deleteArticleAtIndexPath:indexPath];
        return YES;
    }],[MGSwipeButton buttonWithTitle:@"More" backgroundColor:[UIColor flatGrayColor] callback:^BOOL(MGSwipeTableCell *sender) {
        return YES;
    }]];
    cell.rightExpansion.buttonIndex = 0;
    cell.rightExpansion.threshold = 2.0;
    cell.rightExpansion.fillOnTrigger = YES;
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
}

#pragma mark - NSFetchedResultsController and CoreData fetch

-(NSFetchedResultsController *)fetchedResultsController {
    if(_fetchedResultsController != nil)
        return _fetchedResultsController;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchRequest *fetchRequest = [Article fetchRequest];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    fetchRequest.sortDescriptors = @[nameSort];
    [fetchRequest setFetchBatchSize:20];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[[CoreDataManager sharedManager] persistentContainer] viewContext] sectionNameKeyPath:nil cacheName:nil];
    
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}


-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] forIndexPath:indexPath];
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
