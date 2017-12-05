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
#import "ArticleInfoViewController.h"

@interface ArticleListViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) CoreDataManager *manager;
@property (strong, nonatomic) APISession *session;
@property (strong, nonatomic) ArticleInfoViewController *articleInfoController;

@end

static NSString *articleCellID = @"ArticleCell";
static NSString *showArticleInfoSegueID = @"ShowArticleInfoSegue";

@implementation ArticleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    self.manager = [CoreDataManager sharedManager];
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSError *fetchError = nil;
    if(![[self fetchedResultsController]performFetch:&fetchError]){
        NSLog(@"Unresolved Error: %@, %@", fetchError, [fetchError userInfo]);
        exit(-1);
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [self.tableView setTableFooterView:[UIView new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    if(self.manager.storedSpeech){
        NSLog(@" did appear : %@",self.manager.storedSpeech.capitalizedString);
        self.navigationItem.title = self.manager.storedSpeech.capitalizedString;
        [APISession createArticlesJSONDataSession:self.manager.storedSpeech.lowercaseString withCompletionBlock:nil];
        self.manager.storedSpeech = nil;
    } else {
        NSLog(@"%@",self.manager.selectedCategory.name.lowercaseString);
        self.navigationItem.title = self.manager.selectedCategory.name.capitalizedString;
        [APISession createArticlesJSONDataSession:self.manager.selectedCategory.name.lowercaseString withCompletionBlock:nil];
    }
}

/*
 @brief - This function is called every time a MOC is updated in the app. Configured in the view did load. We know that data has changed and hence we check to see if it is data we care about
 We check to see if we are on the main therad, if we are not on the main thread we recursively call ourselves from the main thread and wait. This will guarantee that what happens next will always be on the main thread.
 The final line of code is the kicker - it tells the main NSManagedObjectContext that the underlying data has changed and that it needs to update itself. This will in turn cause the NSFetchedResultsController to get woken up which finally updates the UI.
 @param notificaton - the notification that is triggered from our viewDidLoad
 */
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSUInteger count = [sectionInfo numberOfObjects];
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:articleCellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:articleCellID];
    }
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.manager.selectedArticle = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self performSegueWithIdentifier:showArticleInfoSegueID sender:self];
}

-(void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:article.author];
    [cell.detailTextLabel setText:article.title];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            Article *articleToDelete = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            [self.manager.persistentContainer.viewContext deleteObject:articleToDelete];
            NSError *deleteError = nil;
            [[_fetchedResultsController managedObjectContext] save:&deleteError];
            if(deleteError)
                NSLog(@"Unresolved Error: %@, %@", deleteError, [deleteError userInfo]);
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - NSFetchedResultsController

-(NSFetchedResultsController *)fetchedResultsController {
    if(_fetchedResultsController != nil)
        return _fetchedResultsController;
    
    [NSFetchedResultsController deleteCacheWithName:nil];
    NSFetchRequest *fetchRequest = [Article fetchRequest];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"publishedate" ascending:YES];
    fetchRequest.sortDescriptors = @[dateSort];
    [fetchRequest setFetchBatchSize:20];
    
    if(self.manager.storedSpeech){
        NSLog(@"Stored : %@", self.manager.storedSpeech.lowercaseString);
        NSPredicate *correctCategory = [NSPredicate predicateWithFormat:@"source.category.name == %@", self.manager.storedSpeech.lowercaseString];
        [fetchRequest setPredicate:correctCategory];
    } else {
        NSPredicate *correctCategory = [NSPredicate predicateWithFormat:@"source.category.name == %@", self.manager.selectedCategory.name];
        [fetchRequest setPredicate:correctCategory];
    }
    

    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[[[CoreDataManager sharedManager] persistentContainer] viewContext] sectionNameKeyPath:nil cacheName:nil];
    
    
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    self.manager.storedSpeech = nil;
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
