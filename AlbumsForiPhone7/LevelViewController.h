//
//  LevelViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/13/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelViewController : UIViewController
{

}

@property (nonatomic, retain) NSString *campaignType;
@property (nonatomic, retain) NSNumber *levelSelected;
@property (nonatomic, retain) NSNumber *score;

- (IBAction)back:(id)sender;

@end
