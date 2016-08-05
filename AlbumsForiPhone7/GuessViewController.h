//
//  GuessViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/15/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GuessViewController : UIViewController
{
    int strikes;
}

@property (nonatomic, retain) NSNumber *albumID;
@property (nonatomic, retain) NSNumber *levelSelected;
@property (nonatomic, retain) NSNumber *score;
@property (nonatomic, retain) NSString *campaignType;

- (void)updateHints;
- (int)updateMaxScore:(int)curMaxScore;
- (NSString *)levelAchievementGained:(int)guessedTotal;

- (IBAction)back:(id)sender;
- (IBAction)makeGuess:(id)sender;
- (IBAction)getRidOfLater:(id)sender;
- (IBAction)showHint:(id)sender;


-(void)setUpLargeCover;
-(void)backToSmallCover;


@end
