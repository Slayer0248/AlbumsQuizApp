//
//  CampaignSelectionViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/11/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "CampaignSelectionViewController.h"
#import "GameViewController.h"
#import "LevelSelectViewController.h"
#import "DBAccess.h"
#import "UIDevice-Hardware.h"

@interface CampaignSelectionViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UIButton *albumsCampaign;
@property (nonatomic, strong) UIButton *artistsCampaign;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@property (nonatomic, strong) NSString *segueOnHold;
@property (nonatomic, strong) NSString *modeOnHold;

@property (nonatomic, strong) UILabel *promptMessage;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *noResetButton;
@property (nonatomic, strong) UIButton *undoSelectionButton;
@property (nonatomic, strong) UIView *strikesResetPrompt;
@property (nonatomic, strong) UIImageView *lockedIndicator;


@property (nonatomic, strong) DBAccess *dba;

@property (nonatomic, strong) UIDevice_Hardware *testDevice;

@end

@implementation CampaignSelectionViewController

@synthesize gameType;

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
    
    NSLog(@"%@", gameType);
    
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
        self.artistsCampaign = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.artistsCampaign setImage:[UIImage imageNamed:@"ArtistsCampaignButton.png"] forState:UIControlStateNormal];
        [self.artistsCampaign setFrame:CGRectMake(5, 0, self.view.window.frame.size.width-10, 230)];
        
        [self.albumsCampaign setTag:0];
        [self.artistsCampaign addTarget:self action:@selector(startCampaignWithButton:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell addSubview:self.artistsCampaign];
    }
    if (indexPath.item == 1) {
        self.albumsCampaign = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.albumsCampaign setImage:[UIImage imageNamed:@"AlbumsCampaignButton.png"] forState:UIControlStateNormal];
        [self.albumsCampaign setFrame:CGRectMake(5, 0, self.view.window.frame.size.width-10, 230)];
        [self.albumsCampaign setTag:1];
        [self.albumsCampaign addTarget:self action:@selector(startCampaignWithButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.albumsCampaign];
        
        //set up lock if not unlocked
        if ([gameType isEqualToString:@"levels"] &&
            [self.dba getAchievementStateFor:@"artistsLevel8Done"] == 0) {
            
            self.lockedIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LockedIndicator.png"]];
            [self.lockedIndicator setFrame:CGRectMake((self.view.window.frame.size.width*.5) -100, 15, 200, 200)];
            
            [cell addSubview:self.lockedIndicator];
        }
    }
    
    
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.window.frame.size.width, 230);
    return cellSize;
}

/* Method designed to set up and add a strikesResetPrompt to the view
 * controller.
 */
-(void)setupResetView {
    
    
    //initialize strikesResetPrompt
    if(IS_IPHONE5) {
        self.strikesResetPrompt = [[UIView alloc] initWithFrame:CGRectMake(34, 193, 252, 172)];
    } else {
        self.strikesResetPrompt = [[UIView alloc] initWithFrame:CGRectMake(34, 133, 252, 172)];
    }

    
    //set strikesResetPrompt background color
    [self.strikesResetPrompt setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    
    //set up promptMessage
    self.promptMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 252, 62)];
    [self.promptMessage setNumberOfLines:0];
    [self.promptMessage setTextAlignment:NSTextAlignmentCenter];
    [self.promptMessage setText:@"A strikes mode game was in progress. Would you like to continue it?"];
    [self.promptMessage setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    [self.promptMessage setTextColor:[self colorWithHexString:@"ffffff"]];
    
    //set up resetButton
    self.resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton setBackgroundImage:[UIImage imageNamed:@"resetButton.png"] forState:UIControlStateNormal];
    self.resetButton.frame = CGRectMake(29, 80, 74, 44);
    
    //set up noResetButton
    self.noResetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.noResetButton addTarget:self action:@selector(continueLastGame) forControlEvents:UIControlEventTouchUpInside];
    [self.noResetButton setBackgroundImage:[UIImage imageNamed:@"noResetButton.png"] forState:UIControlStateNormal];
    self.noResetButton.frame = CGRectMake(149, 80, 74, 44);
    
    //set up undoSelectionButton
    self.undoSelectionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.undoSelectionButton addTarget:self action:@selector(undoSelection) forControlEvents:UIControlEventTouchUpInside];
    [self.undoSelectionButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonAngled.png"] forState:UIControlStateNormal];
    self.undoSelectionButton.frame = CGRectMake(89, 126, 74, 44);
    
    
    //add UI elements to strikesResetPrompt
    [self.strikesResetPrompt addSubview:self.promptMessage];
    [self.strikesResetPrompt addSubview:self.resetButton];
    [self.strikesResetPrompt addSubview:self.noResetButton];
    [self.strikesResetPrompt addSubview:self.undoSelectionButton];
    
    
    //add strikesResetPrompt to CampaignSelectViewController
    [self.view addSubview:self.strikesResetPrompt];
}

-(void)startCampaignWithButton:(UIButton *)sender {
    NSString *segue;
    NSLog(@"%ld", (long)sender.tag);
    
    if ((long)sender.tag == 0) {
        //artist segues
        if ([gameType isEqualToString:@"baseball"]) {
            

            //check if past games progress is still in the database table
            if([self.dba getTotalStrikeModifiedForMode:@"artists"] == 0) {
                segue = @"artistsBaseball";
                [self performSegueWithIdentifier:segue sender:self];
            }
            else {
                //if so, display view asking if we want to continue with saved data, or start from scratch
                self.segueOnHold = @"artistsBaseball";
                self.modeOnHold = @"artists";
                [self setupResetView];
            }
            
            
        } else if ([gameType isEqualToString:@"levels"]) {
            
            segue = @"artistsLevels";
            [self performSegueWithIdentifier:segue sender:self];
        }
        
        
        
    } else if((long)sender.tag == 1) {
        if ([gameType isEqualToString:@"baseball"]) {
            
            //check if past games progress is still in the database table
            if([self.dba getTotalStrikeModifiedForMode:@"albums"] == 0) {
                segue = @"albumsBaseball";
                [self performSegueWithIdentifier:segue sender:self];
            }
            else {
                //if so, display view asking if we want to continue with saved data, or start from scratch
                self.segueOnHold = @"albumsBaseball";
                self.modeOnHold = @"ablums";
                [self setupResetView];
            }
            
        } else if ([gameType isEqualToString:@"levels"]) {
            
            segue = @"albumsLevels";
            if ([self.dba getAchievementStateFor:@"artistsLevel8Done"] == 1 ||
                [[self.testDevice hardwareSimpleDescription] isEqualToString:@"Simulator"]) {
                
                    [self performSegueWithIdentifier:segue sender:self];
            }
        }
        
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    //Levels segues
    if([segue.identifier isEqualToString:@"albumsLevels"]) {
        NSString *campaign = @"albums";
        
        LevelSelectViewController *lSelect = [segue destinationViewController];
        lSelect.campaignType = campaign;
        
        //Modify later
        lSelect.score = [[NSNumber alloc] initWithInt:[self.dba getStat:@"albumLevels"]];
        
    } else if([segue.identifier isEqualToString:@"artistsLevels"]) {
        NSString *campaign = @"artists";
        
        LevelSelectViewController *lSelect = [segue destinationViewController];
        lSelect.campaignType = campaign;
        
        //Modify later
        lSelect.score = [[NSNumber alloc] initWithInt:[self.dba getStat:@"artistLevels"]];
    }

    
    
    //Baseball Game Segues
    else if([segue.identifier isEqualToString:@"albumsBaseball"]) {
        NSString *campaign = @"albums";

        GameViewController *baseball = [segue destinationViewController];
        baseball.campaignType = campaign;
        
        
    } else if([segue.identifier isEqualToString:@"artistsBaseball"]) {
        NSString *campaign = @"artists";
        
        GameViewController *baseball = [segue destinationViewController];
        baseball.campaignType = campaign;
    }
}

-(void)reset {
    [self.strikesResetPrompt removeFromSuperview];
    
    //perform reset of strikes db in selected mode
    if ([self.modeOnHold isEqualToString:@"albums"]) {
        
        [self.dba resetStrikesInMode:self.modeOnHold];
        [self.dba setStat:@"albumStrikes" toValue:0];
        [self.dba setStat:@"albumOuts" toValue:3];
        
    } else if([self.modeOnHold isEqualToString:@"artists"]) {
        
        [self.dba resetStrikesInMode:self.modeOnHold];
        [self.dba setStat:@"artistStrikes" toValue:0];
        [self.dba setStat:@"artistOuts" toValue:3];
        
        
    }
    
    [self performSegueWithIdentifier:self.segueOnHold sender:self.resetButton];
    
}

-(void)continueLastGame {
    [self.strikesResetPrompt removeFromSuperview];
    
    //don't reset
    [self performSegueWithIdentifier:self.segueOnHold sender:self.noResetButton];

}

-(void)undoSelection {
    [self.strikesResetPrompt removeFromSuperview];
    self.segueOnHold = @"";
    self.modeOnHold = @"";
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
