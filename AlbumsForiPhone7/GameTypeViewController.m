//
//  GameTypeViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/11/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "GameTypeViewController.h"
#import "CampaignSelectionViewController.h"
#import "AlbumCell.h"
#import "DBAccess.h"
#import "UIDevice-Hardware.h"

@interface GameTypeViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) UIButton *levelsGame;
@property (nonatomic, strong) UIButton *baseballGame;
@property (nonatomic, strong) UIImageView *lockedIndicator;


@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) DBAccess *dba;

@property (nonatomic, strong) UIDevice_Hardware *testDevice;


@end

@implementation GameTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];

    [self.collectionView setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];

    if (IS_IPHONE5) {
        [self.collectionView setFrame:CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.collectionView setFrame:CGRectMake(0, 68+20, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
    
    } else {
        [self.collectionView setFrame:CGRectMake(0, 60, self.view.frame.size.width, 392)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    
    self.dba = [[DBAccess alloc] init];
    self.testDevice = [[UIDevice_Hardware alloc] init];
    
}

#pragma mark - UICollectionView Datasource
// returns the number of cells to be displayed for a given section
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
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

    
    if (indexPath.item == 0) {
        self.levelsGame = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.levelsGame setImage:[UIImage imageNamed:@"LevelCampaignButton.png"] forState:UIControlStateNormal];
        [self.levelsGame setFrame:CGRectMake(5, 0, self.view.window.frame.size.width-10, 230)];
        [self.levelsGame addTarget:self action:@selector(startLevelCampaign) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.levelsGame];
        //NSLog(@"success");
        
    }
    if (indexPath.item == 1) {
        self.baseballGame = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.baseballGame setImage:[UIImage imageNamed:@"StrikesButton.png"] forState:UIControlStateNormal];
        [self.baseballGame setFrame:CGRectMake(5, 0, self.view.window.frame.size.width-10, 230)];
        [self.baseballGame addTarget:self action:@selector(startBaseballCampaign) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.baseballGame];
        
        //set up lock if not unlocked
        if ([self.dba getAchievementStateFor:@"albumsLevel8Done"] == 0) {
            self.lockedIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LockedIndicator.png"]];
            [self.lockedIndicator setFrame:CGRectMake((self.view.window.frame.size.width*.5) -100, 15, 200, 200)];
            
            [cell addSubview:self.lockedIndicator];
        }
        //NSLog(@"done");
    }
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.window.frame.size.width, 230);
    return cellSize;
}

-(void) startLevelCampaign {
    [self performSegueWithIdentifier:@"levels" sender:self];
    
}

-(void) startBaseballCampaign {
    if ([self.dba getAchievementStateFor:@"albumsLevel8Done"] == 1 || [[self.testDevice hardwareSimpleDescription] isEqualToString:@"Simulator"]) {
        [self performSegueWithIdentifier:@"baseball" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"baseball"]) {
        
        NSString *type = @"baseball";
        CampaignSelectionViewController *cSelection =[segue destinationViewController];
        cSelection.gameType = type;
        
    } else  if([segue.identifier isEqualToString:@"levels"]) {
        
        NSString *type = @"levels";
        CampaignSelectionViewController *cSelection =[segue destinationViewController];
        cSelection.gameType = type;
        
    }
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
