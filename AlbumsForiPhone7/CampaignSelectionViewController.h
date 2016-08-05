//
//  CampaignSelectionViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/11/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampaignSelectionViewController : UIViewController
{
    
    NSString *gameType;
}

@property (nonatomic, retain) NSString *gameType;

-(void)startCampaignWithButton: (UIButton *)sender;

//setup view to prompt to reset strikes progress
-(void)setupResetView;

//button actions
-(void)reset;
-(void)continueLastGame;
-(void)undoSelection;

@end
