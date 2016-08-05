//
//  GameViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

@interface GameViewController : UIViewController {
    
    NSString *campaignType;
    
    int score;
    int strikes;
    int outs;
    int maxScore;

}

@property (nonatomic, retain) NSString *gameType;
@property (nonatomic, retain) NSString *campaignType;



- (IBAction)back:(id)sender;
- (IBAction)makeGuess:(id)sender;
- (IBAction)noIdea:(id)sender;


-(void)setUpLargeCover;
-(void)backToSmallCover;


@end
