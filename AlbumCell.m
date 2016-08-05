//
//  AlbumCell.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/14/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

@synthesize coverView, guessStateView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        coverView = [[UIImageView alloc] init];
        //[coverView setFrame:frame];
        //[self addSubview:coverView];
        
        guessStateView = [[UIImageView alloc] init];
        //[guessStateView setFrame:CGRectMake(coverView.frame.origin.x + coverView.frame.size.width -15, coverView.frame.origin.y + coverView.frame.size.height -15, 15, 15)];
        //[self addSubview:coverView];*/
    }
    return self;
}

-(void) setCover:(UIImage *)cover{
    self.coverView.image = cover;
    
}

-(void) setGuess:(UIImage *)stateView{
    self.guessStateView.image = stateView;
    //[self.guessStateView setFrame:CGRectMake(self.frame.origin.x + self.frame.size.width -20, self.frame.origin.y + self.frame.size.height -20, 20, 20)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
