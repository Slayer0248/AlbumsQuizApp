//
//  SettingsViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//
#import "UIDevice-Hardware.h"
#import "SettingsViewController.h"
#import "DBAccess.h"

@interface SettingsViewController ()

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *clearHighscoresButton;
@property (strong, nonatomic) IBOutlet UIButton *clearProgressButton;

@property (nonatomic, strong) IBOutlet UILabel *audioSettingsLabel;
@property (nonatomic, strong) IBOutlet UILabel *soundEffectsLabel;

@property (strong, nonatomic) IBOutlet UIButton *soundEffectsSwitchButton;

@property (nonatomic, strong) DBAccess *dba;
@property (nonatomic, strong) UILabel *statusLabel;


@end

@implementation SettingsViewController

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
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];

    
    //set positions of UI Elements
    if (IS_IPHONE5) {
        
        [self.backButton setFrame:CGRectMake(15, 17, 72, 44)];
        [self.audioSettingsLabel setFrame:CGRectMake(123, 69, 75, 40)];
        [self.soundEffectsLabel setFrame:CGRectMake(52, 113, 120, 24)];
        [self.soundEffectsSwitchButton setFrame:CGRectMake(181, 110, 79, 30)];
        [self.clearHighscoresButton setFrame:CGRectMake(91, self.view.frame.size.height -127, 139, 44)];
        [self.clearProgressButton setFrame:CGRectMake(91, self.clearHighscoresButton.frame.origin.y-56, 139, 44)];
        
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        
        //copy this new check to rest of app
        
        //add status bar height to y parameters (2nd)
        //status bar height = 20
        
        [self.backButton setFrame:CGRectMake(15, 17+20, 72, 44)];
        [self.audioSettingsLabel setFrame:CGRectMake(123, 69+20, 75, 40)];
        [self.soundEffectsLabel setFrame:CGRectMake(52, 113+20, 120, 24)];
        [self.soundEffectsSwitchButton setFrame:CGRectMake(181, 110+20, 79, 30)];
        [self.clearHighscoresButton setFrame:CGRectMake(91, self.view.frame.size.height -127, 139, 44)];
        [self.clearProgressButton setFrame:CGRectMake(91, self.clearHighscoresButton.frame.origin.y-56, 139, 44)];

    
    
    } else {
        
        [self.backButton setFrame:CGRectMake(15, 17, 72, 44)];
        //[self.backButton setFrame:CGRectMake(15, 17, 36, 22)];
        [self.audioSettingsLabel setFrame:CGRectMake(123, 69, 75, 40)];
        [self.soundEffectsLabel setFrame:CGRectMake(52, 113, 120, 24)];
        [self.soundEffectsSwitchButton setFrame:CGRectMake(181, 110, 79, 30)];
        [self.clearHighscoresButton setFrame:CGRectMake(91, self.view.frame.size.height -130, 139, 44)];
        [self.clearProgressButton setFrame:CGRectMake(91, self.clearHighscoresButton.frame.origin.y-56, 139, 44)];
        
    }
    
    
    //set background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //set text color of the uilabels
    [self.audioSettingsLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.soundEffectsLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    
    
    self.dba = [[DBAccess alloc] init];
    int playSounds = [self.dba getSetting:@"playSounds"];
    
    
    if (playSounds == 1) {
        [self.soundEffectsSwitchButton setBackgroundImage:[UIImage imageNamed:@"switchButtonOn.png"] forState:UIControlStateNormal];
    } else if (playSounds == 0) {
        [self.soundEffectsSwitchButton setBackgroundImage:[UIImage imageNamed:@"switchButtonOff.png"] forState:UIControlStateNormal];
    }
    //self.playSounds = TRUE;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)soundEffectsSettingChanged:(id)sender {
    
    int playSounds = [self.dba getSetting:@"playSounds"];
    int stateChanged = 0;
    
    if (playSounds == 0) {
        [self.soundEffectsSwitchButton setBackgroundImage:[UIImage imageNamed:@"switchButtonOn.png"] forState:UIControlStateNormal];
        [self.dba setSetting:@"playSounds" toValue:1];
        stateChanged = 1;
    }
    else if (stateChanged == 0) {
        [self.soundEffectsSwitchButton setBackgroundImage:[UIImage imageNamed:@"switchButtonOff.png"] forState:UIControlStateNormal];
        [self.dba setSetting:@"playSounds" toValue:0];
        
    }
}

- (IBAction)clearHighscores:(id)sender {
    
    //clear highscores
    [self.dba clearHighscoresList];
    
    //set up statusLabel
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, self.view.frame.size.height - 54, 161, 42)];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.statusLabel setNumberOfLines:0];
    [self.statusLabel setBackgroundColor:[self colorWithHexString:@"00234b"]];
    [self.statusLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.statusLabel setText:@"Highscore list was cleared successfully!"];
    
    //add UI elements
    [self.view addSubview:self.statusLabel];
    
    //wait 5 seconds then remove
    [self performSelector:@selector(removeStatusMessage) withObject:nil afterDelay:5];
}

- (IBAction)clearProgress:(id)sender {
    
    
    //set database table to default values for the following tables
    
    //reset albumHints table
    [self.dba resetAlbumHints];
    
    //reset artistHints table
    [self.dba resetArtistHints];
    
    //reset albumProgress table
    //reset artistProgress table
    [self.dba resetAllProgress];
    
    //reset achievements table
    [self.dba resetAllAchievements];
    
    
    //reset overallStats table
    [self.dba resetAllStats];
    
    
    //set up statusLabel
    self.statusLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, self.view.frame.size.height - 54, 161, 42)];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.statusLabel setNumberOfLines:0];
    [self.statusLabel setBackgroundColor:[self colorWithHexString:@"00234b"]];
    [self.statusLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.statusLabel setText:@"Game progress was cleared successfully!"];
    
    //add UI elements
    [self.view addSubview:self.statusLabel];
    
    //wait 5 seconds then remove
    [self performSelector:@selector(removeStatusMessage) withObject:nil afterDelay:5];

    
}

- (void)removeStatusMessage {
    [self.statusLabel removeFromSuperview];
    
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
