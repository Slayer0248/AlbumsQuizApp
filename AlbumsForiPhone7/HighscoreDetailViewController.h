//
//  HighscoreDetailViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/29/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "ViewController.h"

@interface HighscoreDetailViewController : ViewController
{
    NSNumber *rank;
    NSString *name;
    NSString *score;
    NSString *mode;
}

@property (nonatomic, strong) NSNumber *rank;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *mode;

@end
