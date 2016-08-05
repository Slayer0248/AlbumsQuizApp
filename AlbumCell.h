//
//  AlbumCell.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/14/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UICollectionViewCell
{
    UIImageView *coverView;
    UIImageView *guessStateView;
}

@property (nonatomic, retain) IBOutlet UIImageView *coverView;
@property (nonatomic, retain) IBOutlet UIImageView *guessStateView;

-(void) setCover:(UIImage *)cover;
-(void) setGuess:(UIImage *)stateView;

@end
