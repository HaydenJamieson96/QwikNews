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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionViewData = [NSMutableArray array];
    self.manager = [CoreDataManager sharedManager];
    [APISession createCategoryJSONDataSession:^{
         [self fetchCoreData];
    }];
    
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    self.speechRecognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                NSLog(@"Authorized");
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                NSLog(@"Denied");
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                NSLog(@"Not Determined");
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                NSLog(@"Restricted");
                break;
            default:
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Speech to text recognition

- (IBAction)recordUser:(id)sender {
    if (self.audioEngine.isRunning) {
        [self.audioEngine stop];
        [self.recognitionRequest endAudio];
    } else {
        [self startListening];
        if(self.recordedString){
            //perform segue and pass string across
        }
        self.recordedString = nil;
    }
}

/*
 @brief - Initialises an AVAudioEngine, makes sure no recog task currently running. Starts AVAudio session, then starts a recognition process.
          In the block it grabs the users input, or stops the audio process if theres an error
 */
- (void)startListening {
    self.audioEngine = [[AVAudioEngine alloc] init];

    if (self.recognitionTask) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    self.recognitionRequest.shouldReportPartialResults = YES;
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:self.recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        BOOL isFinal = NO;
        if (result) {
            self.recordedString = result.bestTranscription.formattedString;
            NSLog(@"RESULT:%@",result.bestTranscription.formattedString);
            isFinal = !result.isFinal;
        }
        if (error) {
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
        }
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    NSLog(@"Say Something, I'm listening");
}

#pragma mark - SFSpeechRecognizerDelegate Delegate Methods

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    NSLog(@"Availability:%d",available);
}

#pragma mark - Image Picker Controller

- (IBAction)selectImage:(id)sender {
    
}


#pragma mark - Fetch CoreData

/*
 @brief - Perform a fetch request for the Category entity, sorting by category field. Append each Category object into array for collection view data source
 
 */
-(void)fetchCoreData {
    NSFetchRequest *fetchRequest = [Category fetchRequest];
    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
    fetchRequest.sortDescriptors = @[categorySort];
    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@", ];
//    [fetchRequest setPredicate:predicate];
    
    //persistentContainer.viewContext;     - this is managed object context
    
//    BOOL unique = YES;
//    NSError  *error;
//    self.collectionViewData = [[[[[CoreDataManager sharedManager] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&error]mutableCopy];
//    if(self.collectionViewData.count > 0){
//        for(Category *thisCategory in self.collectionViewData){
//            if([thisCategory.identifier isEqualToString: ]){
//                unique = NO;
//            }
//        }
//    }
//    if(unique){
//        Category *thisCategory = [NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:[[[CoreDataManager sharedManager] persistentContainer] viewContext]];
//        thisCategory.identifier = //identifier?;
//        NSError *error= nil;
//        if (![[[[CoreDataManager sharedManager] persistentContainer] viewContext] save:&error]) {
//            return;
//        }
//    }
    
   
    
//    Category *category = nil;
//    for(category in categories?){
//        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id == %@", category.identifier];
//
//         self.collectionViewData = [[[[[CoreDataManager sharedManager] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&fetchError] mutableCopy];
//        if(self.collectionViewData.count == 0){
//            //found no duplicates so insert new one
//
//        }
//    }
    
    
    NSError *fetchError = nil;
    self.collectionViewData = [[[[[CoreDataManager sharedManager] persistentContainer] viewContext] executeFetchRequest:fetchRequest error:&fetchError] mutableCopy];
    
    if (fetchError) {
        NSLog(@"Error fetching data %@", [fetchError localizedDescription]);
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            NSLog(@"RELOADED");
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
        cell.contentView.layer.cornerRadius = 10.f;
        cell.contentView.layer.backgroundColor = [UIColor colorWithRed:0.994 green:0.440 blue:0.348 alpha:0.6].CGColor;
        cell.contentView.layer.borderWidth = 1.0f;
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
