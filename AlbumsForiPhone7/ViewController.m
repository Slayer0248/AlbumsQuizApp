//
//  ViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import "ViewController.h"
#import "UIDevice-Hardware.h"
#import "GameTypeViewController.h"
#import "HighscoresViewController.h"
#import "StoreViewController.h"
#import "SettingsViewController.h"
#import "HelpAndAboutViewController.h"



@interface ViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, weak) IBOutlet UIImageView *iconGraphic;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *highscoresButton;
@property (nonatomic, strong) UIButton *storeButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *helpAndAboutButton;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;





@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //position buttons and set background image
    //UIImage *menuButtonImage = [UIImage ]
    
    //NSLog(@"RESOLUTION = %@", NSStringFromCGSize([UIScreen mainScreen].bounds.size));
    
    //set up collectionVeiw
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.collectionView setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    
    
    //set positions of UI elements on different sized screens
    //CGRect screenBounds = [[UIScreen mainScreen] bounds];
    if (IS_IPHONE5) {
        
        //view height = 548
        [self.iconGraphic setFrame:CGRectMake(20, 20, 224, 224)];
        [self.collectionView setFrame:CGRectMake(0, 249, self.view.frame.size.width, self.view.frame.size.height - 249)];

    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        
        //copy this new check to rest of app
        
        //add status bar height to y parameters (2nd)
        //status bar height = 20
        [self.iconGraphic setFrame:CGRectMake(20, 20, 224, 224)];
        [self.collectionView setFrame:CGRectMake(0, 249+20, self.view.frame.size.width, self.view.frame.size.height - 249)];

    }
    else {
        //view height = 460
        [self.iconGraphic setFrame:CGRectMake(20, 20, 224, 224)];
        [self.collectionView setFrame:CGRectMake(0, 249, self.view.frame.size.width, self.view.frame.size.height - 249)];
       
    }
    
    
    /* UI notes
     *
     * space between large app icon & sides of screen = 20
     * space between large app icon & first menu button = 10
     * space between menu buttons = 6
     */
    
    
    
    
    //self.playButton.frame = CGRectMake(self.playButton.frame.origin.x,
    //                                 self.iconGraphic.bounds.origin.y + self.iconGraphic.bounds.size.height,
    //                               250, 50);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
// returns the number of cells to be displayed for a given section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

// returns the total number of sections (all cells)
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

// responsible for returning the cell at a given index path. For now, this just returns an empty UICollectionViewCell.
-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"MenuCell" forIndexPath:indexPath];
    cell.backgroundColor = [self colorWithHexString:@"0058bb"];
    //NSLog(@"%d.....%d", indexPath.item, indexPath.row);
    [cell removeFromSuperview];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    if (indexPath.item == 0) {
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setBackgroundImage:[UIImage imageNamed:@"MainMenuButton.png"] forState:UIControlStateNormal];
        [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
        self.playButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.playButton setFrame:CGRectMake(70, 0, 250, 50)];
        [self.playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.playButton];
        //NSLog(@"success");
        
    }
    else if (indexPath.item == 1) {
        self.highscoresButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.highscoresButton setBackgroundImage:[UIImage imageNamed:@"MainMenuButton.png"] forState:UIControlStateNormal];
        [self.highscoresButton setTitle:@"Highscores" forState:UIControlStateNormal];
        self.highscoresButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.highscoresButton setFrame:CGRectMake(70, 0, 250, 50)];
        [self.highscoresButton addTarget:self action:@selector(highscores) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.highscoresButton];
        
        /*Example of underlined UIbutton title for highscoresButton*/
        /*NSDictionary *attrDict = @{NSFontAttributeName : [UIFont systemFontOfSize:15.0],NSForegroundColorAttributeName : [UIColor whiteColor]};
         NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Highscores" attributes: attrDict];
         NSString *commentString= @"Highscores";
         [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
         [self.highscoresButton setAttributedTitle:title forState:UIControlStateNormal];*/
        
        
        //NSLog(@"done");
    }
    else if (indexPath.item == 2) {
        self.storeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.storeButton setBackgroundImage:[UIImage imageNamed:@"MainMenuButton.png"] forState:UIControlStateNormal];
        [self.storeButton setTitle:@"Store" forState:UIControlStateNormal];
        self.storeButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.storeButton setFrame:CGRectMake(70, 0, 250, 50)];
        [self.storeButton addTarget:self action:@selector(store) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.storeButton];
        
        
        //NSLog(@"done");
    }
    else if (indexPath.item == 3) {
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.settingsButton setBackgroundImage:[UIImage imageNamed:@"MainMenuButton.png"] forState:UIControlStateNormal];
        self.settingsButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.settingsButton setTitle:@"Settings" forState:UIControlStateNormal];
        [self.settingsButton setFrame:CGRectMake(70, 0, 250, 50)];
        [self.settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.settingsButton];
        
        
        //NSLog(@"done");
    }
    else if (indexPath.item == 4) {
        self.helpAndAboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.helpAndAboutButton setBackgroundImage:[UIImage imageNamed:@"MainMenuButton.png"] forState:UIControlStateNormal];
        self.helpAndAboutButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self.helpAndAboutButton setTitle:@"Help & About" forState:UIControlStateNormal];
        [self.helpAndAboutButton setFrame:CGRectMake(70, 0, 250, 50)];
        [self.helpAndAboutButton addTarget:self action:@selector(helpAndAbout) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.helpAndAboutButton];
    }
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.window.frame.size.width, 50);
    return cellSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(3, 0, 3, 0);
}


#pragma mark - Button selectors

-(void)play {
    [self performSegueWithIdentifier:@"play" sender:self];
    
}


-(void)settings {
    [self performSegueWithIdentifier:@"settings" sender:self];
}


-(void)highscores {
    [self performSegueWithIdentifier:@"highscores" sender:self];
}

-(void)store {
    [self performSegueWithIdentifier:@"store" sender:self];
}

-(void)helpAndAbout {
    [self performSegueWithIdentifier:@"helpAndAbout" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"play"]) {
        GameTypeViewController *vc = [segue destinationViewController];
    }
    else if([segue.identifier isEqualToString:@"highscores"]) {
        HighscoresViewController *vc = [segue destinationViewController];
    }
    else if([segue.identifier isEqualToString:@"store"]) {
        StoreViewController *vc = [segue destinationViewController];
    }
    else if([segue.identifier isEqualToString:@"settings"]) {
        SettingsViewController *vc = [segue destinationViewController];
    }
    else if([segue.identifier isEqualToString:@"helpAndAbout"]) {
        HelpAndAboutViewController *vc = [segue destinationViewController];
    }
}



/*
 * Method to create UIColor from hexidecimal string
 */

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}



@end
