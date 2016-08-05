//
//  HighscoresHeaderView.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/26/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighscoresHeaderView : UICollectionReusableView
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;

@end
