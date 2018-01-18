//
//  CategoriesViewController.h
//  QwikNews
//
//  Created by Hayden Jamieson on 11/27/17.
//  Copyright © 2017 Hayden Jamieson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Speech/Speech.h"

@interface CategoriesViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SFSpeechRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *recordedString;
@property (strong, nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (strong, nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (strong, nonatomic) SFSpeechRecognitionTask *recognitionTask;
@property (strong, nonatomic) AVAudioEngine *audioEngine;
- (IBAction)recordUser:(id)sender;
- (IBAction)selectImage:(id)sender;

@end
