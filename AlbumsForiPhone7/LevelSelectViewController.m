//
//  LevelSelectViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/13/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "CampaignSelectionViewController.h"
#import "LevelViewController.h"
#import "DBAccess.h"
#import "UIDevice-Hardware.h"

@interface LevelSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

    @property (nonatomic, strong) NSMutableArray *levelImages;
    @property (nonatomic, strong) NSMutableArray *levelButtonCells;

    @property (nonatomic, strong) NSNumber *selectedLevel;
    @property (nonatomic, strong) IBOutlet UICollectionView *levelSelection;
    @property (nonatomic, strong) IBOutlet UIButton *backButton;
    @property (nonatomic, strong) UIImageView *lockedIndicator;

    @property (nonatomic, strong) DBAccess *dba;

    @property (nonatomic, strong) UIDevice_Hardware *testDevice;

- (IBAction)back:(id)sender;
@end

@implementation LevelSelectViewController
@synthesize campaignType, score;

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
    
    [self.levelSelection setDataSource:self];
    [self.levelSelection setDelegate:self];
    
    [self.levelSelection setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    if (IS_IPHONE5) {
        [self.levelSelection setFrame:CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.levelSelection setFrame:CGRectMake(0, 68+20, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
    } else {
        [self.levelSelection setFrame:CGRectMake(0, 60, self.view.frame.size.width, 392)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    

    //declare arrays
    self.levelImages = [[NSMutableArray alloc] initWithObjects: [UIImage imageNamed:@"LevelIcon1.png"],
                        [UIImage imageNamed:@"LevelIcon2.png"],
                        [UIImage imageNamed:@"LevelIcon3.png"],
                        [UIImage imageNamed:@"LevelIcon4.png"],
                        [UIImage imageNamed:@"LevelIcon5.png"],
                        [UIImage imageNamed:@"LevelIcon6.png"],
                        [UIImage imageNamed:@"LevelIcon7.png"],
                        [UIImage imageNamed:@"LevelIcon8.png"],
                        [UIImage imageNamed:@"ComingSoon.png"],
                        nil];
    self.levelButtonCells = [@[] mutableCopy];
    

    self.dba = [[DBAccess alloc] init];
    self.testDevice = [[UIDevice_Hardware alloc] init];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: Select Item
    if(indexPath.item != 8) {
        UICollectionViewCell *level = self.levelButtonCells[indexPath.item];
        self.selectedLevel = [[NSNumber alloc] initWithInt:(int)indexPath.item + 1];
        
        int curLocked = 1;
        
        if ([campaignType isEqualToString:@"artists"] && ![[self.testDevice hardwareSimpleDescription] isEqualToString:@"Simulator"]) {
            //check corresponding unlocking achievement
            if (indexPath.item == 1) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel1Done"];
            }
            else if (indexPath.item == 2) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel2Done"];
            }
            else if (indexPath.item == 3) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel3Done"];
            }
            else if (indexPath.item == 4) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel4Done"];
            }
            else if (indexPath.item == 5) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel5Done"];
            }
            else if (indexPath.item == 6) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel6Done"];
            }
            else if (indexPath.item == 7) {
                curLocked = [self.dba getAchievementStateFor:@"artistsLevel7Done"];
            }
            
        }
        else if ([campaignType isEqualToString:@"albums"] && ![[self.testDevice hardwareSimpleDescription] isEqualToString:@"Simulator"]) {
            //check corresponding unlocking achievement
            
            
            if (indexPath.item == 1) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel1Done"];
            }
            else if (indexPath.item == 2) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel2Done"];
            }
            else if (indexPath.item == 3) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel3Done"];
            }
            else if (indexPath.item == 4) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel4Done"];
            }
            else if (indexPath.item == 5) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel5Done"];
            }
            else if (indexPath.item == 6) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel6Done"];
            }
            else if (indexPath.item == 7) {
                curLocked = [self.dba getAchievementStateFor:@"albumsLevel7Done"];
            }
            
        }

        if (curLocked == 1) {
            [self performSegueWithIdentifier:@"startLevel" sender:level];
        }
        
        
    }
}

//
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   if ([segue.identifier isEqualToString:@"startLevel"]) {
        //NSLog(@"%ld", (long)self.selectedLevel);
        
        //NSLog([[NSNumber numberWithUnsignedInteger:gameView.levelSelected] stringValue]);
       
       
        //pass data to next view
        LevelViewController *gameView = segue.destinationViewController;
        gameView.levelSelected = self.selectedLevel;
        gameView.campaignType = campaignType;
        gameView.score = self.score;
       
    }
   else if ([segue.identifier isEqualToString:@"backCampaign"]) {
       CampaignSelectionViewController *cView = [segue destinationViewController];
       cView.gameType = @"levels";
       
   }
}


#pragma mark - UICollectionViewDelegate

//returns the number of cells to be displayed for a given section
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.levelImages count];
}

//returns the total number of sections
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}


//returning the cell at a given index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"LevelCell" forIndexPath:indexPath];
    UIImageView *cellImage = [[UIImageView alloc] initWithImage:[self.levelImages objectAtIndex:indexPath.item]];
    [cellImage setFrame:CGRectMake(5, 11, self.view.window.frame.size.width-30, 250)];
    
    [cell addSubview:cellImage];
    
    int curLocked = 1;
    
    if ([campaignType isEqualToString:@"artists"]) {
        //check corresponding unlocking achievement
        
        if (indexPath.item == 1) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel1Done"];
        }
        else if (indexPath.item == 2) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel2Done"];
        }
        else if (indexPath.item == 3) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel3Done"];
        }
        else if (indexPath.item == 4) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel4Done"];
        }
        else if (indexPath.item == 5) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel5Done"];
        }
        else if (indexPath.item == 6) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel6Done"];
        }
        else if (indexPath.item == 7) {
            curLocked = [self.dba getAchievementStateFor:@"artistsLevel7Done"];
        }
 
    }
    else if ([campaignType isEqualToString:@"albums"]) {
        //check corresponding unlocking achievement
        

        if (indexPath.item == 1) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel1Done"];
        }
        else if (indexPath.item == 2) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel2Done"];
        }
        else if (indexPath.item == 3) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel3Done"];
        }
        else if (indexPath.item == 4) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel4Done"];
        }
        else if (indexPath.item == 5) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel5Done"];
        }
        else if (indexPath.item == 6) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel6Done"];
        }
        else if (indexPath.item == 7) {
            curLocked = [self.dba getAchievementStateFor:@"albumsLevel7Done"];
        }

    }
    
    //set up lock if not unlocked
    if (curLocked == 0) {
        
        self.lockedIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LockedIndicator.png"]];
        [self.lockedIndicator setFrame:CGRectMake((self.view.window.frame.size.width*.5) -105, 15, 200, 200)];
        
        [cell addSubview:self.lockedIndicator];
    }
    
    
    [self.levelButtonCells insertObject:cell atIndex:indexPath.item];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(self.view.frame.size.width-10, 305);
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(10, 10, 10, 10);
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


- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"backCampaign" sender:self];
}
@end
