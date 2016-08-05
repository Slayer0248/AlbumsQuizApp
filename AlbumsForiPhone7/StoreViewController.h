//
//  StoreViewController.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/26/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "ViewController.h"

@interface StoreViewController : ViewController


-(IBAction)back:(id)sender;
-(NSMutableArray *)sortNumericPrefixArray:(NSArray*)array toLength:(int)n;

@end

