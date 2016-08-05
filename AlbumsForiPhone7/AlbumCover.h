//
//  AlbumCover.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AlbumCover;

@interface AlbumCover : NSObject

@property (nonatomic, retain) UIImage *questionCover;
@property (nonatomic, retain) UIImage *answerCover;
@property (nonatomic, retain) NSMutableArray *artists;
@property (nonatomic, retain) NSMutableArray *answers;
@property (nonatomic, retain) NSString *artistHint;
@property (nonatomic, retain) NSString *albumHint;


//For quick referrence in strikes mode
@property (nonatomic, retain) NSNumber *albumID;


//last saved visual data
@property (nonatomic, retain) NSNumber *artistLevelsGuessed;
@property (nonatomic, retain) NSNumber *albumLevelsGuessed;
@property (nonatomic, retain) NSNumber *artistStrikesGuessed;
@property (nonatomic, retain) NSNumber *albumStrikesGuessed;

//last saved strikes data
@property (nonatomic, retain) NSNumber *artistStrikesLeft;
@property (nonatomic, retain) NSNumber *albumStrikesLeft;


//last saved score data
@property (nonatomic, retain) NSNumber *artistLevelsScore;
@property (nonatomic, retain) NSNumber *albumLevelsScore;
@property (nonatomic, retain) NSNumber *artistStrikesScore;
@property (nonatomic, retain) NSNumber *albumStrikesScore;


@end
