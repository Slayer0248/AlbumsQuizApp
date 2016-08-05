//
//  EndGameViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface EndGameViewController : UIViewController
{
    NSString *campaignType;
    NSString *labelMessage;
    int *finalScore;
    
}

@property (nonatomic, strong) IBOutlet UIButton *replayButton;
@property (nonatomic, strong) IBOutlet UIButton *mainMenuButton;

@property (nonatomic, retain) NSString *labelMessage;
@property (nonatomic, retain) NSString *campaignType;
@property (nonatomic) int finalScore;

- (IBAction)playAgain:(id)sender;
- (IBAction)mainMenu:(id)sender;

- (void)cancel;
- (void)ok;
- (void)enter;
- (void)setUpSubmitScoreView;


@end
