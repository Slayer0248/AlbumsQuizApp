//
//  EndGameViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import "EndGameViewController.h"
#import "UIDevice-Hardware.h"
#import "GameViewController.h"
#import "DBAccess.h"

@interface EndGameViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UILabel *gameOutcomeLabel;
@property (nonatomic, weak) IBOutlet UILabel *finalScoreLabel;

@property (nonatomic, strong) NSMutableArray *highscores;
@property (nonatomic) int hasPresentedSubmitView;

@property (nonatomic, strong) UILabel *submitMessage;
@property (nonatomic, strong) UIButton *makeHighScore;
@property (nonatomic, strong) UIButton *cancelSubmission;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UIButton *enterButton;
@property (nonatomic, strong) UIView *submitScoreView;

@property (nonatomic, strong) DBAccess *dba;


@end

@implementation EndGameViewController
@synthesize labelMessage, campaignType, replayButton, mainMenuButton;
@synthesize finalScore = _finalScore;

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
    //Game over font size = 54
    //You win font size = 69
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    //set positions of UI Elements
    if (IS_IPHONE5) {
        
        [self.mainMenuButton setFrame:CGRectMake(114, self.view.frame.size.height -92, 93, 44)];
        [self.replayButton setFrame:CGRectMake(114, self.view.frame.size.height - 165, 93, 44)];
        [self.finalScoreLabel setFrame:CGRectMake(20, self.view.frame.size.height -211, 280, 21)];
        [self.gameOutcomeLabel setFrame:CGRectMake(20, self.view.frame.size.height - 359, 280, 121)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        
        [self.mainMenuButton setFrame:CGRectMake(114, self.view.frame.size.height -92, 93, 44)];
        [self.replayButton setFrame:CGRectMake(114, self.view.frame.size.height - 165, 93, 44)];
        [self.finalScoreLabel setFrame:CGRectMake(20, self.view.frame.size.height -211, 280, 21)];
        [self.gameOutcomeLabel setFrame:CGRectMake(20, self.view.frame.size.height - 359, 280, 121)];
    } else {
        
        [self.mainMenuButton setFrame:CGRectMake(114, self.view.frame.size.height -92, 93, 44)];
        [self.replayButton setFrame:CGRectMake(114, self.view.frame.size.height - 165, 93, 44)];
        [self.finalScoreLabel setFrame:CGRectMake(20, self.view.frame.size.height -211, 280, 21)];
        [self.gameOutcomeLabel setFrame:CGRectMake(20, self.view.frame.size.height - 359, 280, 121)];
        
    }
    
    
    //get settings
    self.dba = [[DBAccess alloc] init];
    int playSounds = [self.dba getSetting:@"playSounds"];
    self.hasPresentedSubmitView = 0;
    
    NSLog(@"%@", labelMessage);
    
    //check what the labelMessage is. Will be useful later.
    if ([labelMessage isEqualToString:@"You Win!"]) {
        
        //set up the gameOutcomeLabel
        [self.gameOutcomeLabel setFont:[UIFont systemFontOfSize:69]];
        [self.gameOutcomeLabel setText:labelMessage];
        
        
        //if sound effects are on
        if (playSounds == 1) {
            
            //play YouWinSound.caf audio file
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            CFURLRef soundFileURLREF;
            soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"YouWinSound", CFSTR ("caf"), NULL);
            UInt32 soundID;
            AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
            AudioServicesPlaySystemSound(soundID);
            CFRelease(soundFileURLREF);
        }
        
    } else
        if([labelMessage isEqualToString:@"Game Over"]) {
            
            //set up the gameOutcomeLabel
            [self.gameOutcomeLabel setFont:[UIFont systemFontOfSize:54]];
            [self.gameOutcomeLabel setText:labelMessage];
            
            
            //if sound effects are on
            if (playSounds == 1) {
                
                //play GameOverSound.caf audio file
                CFBundleRef mainBundle = CFBundleGetMainBundle();
                CFURLRef soundFileURLREF;
                soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"GameOverSound", CFSTR ("caf"), NULL);
                UInt32 soundID;
                AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
                AudioServicesPlaySystemSound(soundID);
                CFRelease(soundFileURLREF);
            }
            
        }
    
    //set up the finalScoreLabel
    [self.finalScoreLabel setText:[NSString stringWithFormat:@"Your final score is %d", _finalScore]];
    
    
    //check if there is an option to enter a new highscore
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    //set up high scores array
    self.highscores = [self.dba getHighscores];
    
    
    //check if there is an option to enter a new highscore
    if (self.hasPresentedSubmitView == 0) {
        if ([self.dba highscoreListIsEmpty]) {
            
            [self setUpSubmitScoreView];
            
            [self.replayButton setEnabled:FALSE];
            [self.mainMenuButton setEnabled:FALSE];
            
            NSLog(@"Empty list");
        } else if([self.highscores count]< 20) {
            
            [self setUpSubmitScoreView];
            
            [self.replayButton setEnabled:FALSE];
            [self.mainMenuButton setEnabled:FALSE];
            NSLog(@"partially full list");
            
        } else if([self.dba verifyAsHighscore:_finalScore]) {
            
            [self setUpSubmitScoreView];
            
            [self.replayButton setEnabled:FALSE];
            [self.mainMenuButton setEnabled:FALSE];
            
            NSLog(@"highscore verified");
        }
        
        
        self.hasPresentedSubmitView++;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



/* Method designed to set up and add a submitScoreView to the view
 * controller.
 */
- (void)setUpSubmitScoreView {
    
    
    //initialize submitScoreView
    if(IS_IPHONE5) {
        self.submitScoreView = [[UIView alloc] initWithFrame:CGRectMake(34, 193, 252, 172)];
    } else {
        self.submitScoreView = [[UIView alloc] initWithFrame:CGRectMake(34, 133, 252, 172)];
    }
    
    
    //set submitScoreView background color
    [self.submitScoreView setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    
    //set up submitMessage
    self.submitMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 252, 62)];
    [self.submitMessage setNumberOfLines:0];
    [self.submitMessage setTextAlignment:NSTextAlignmentCenter];
    [self.submitMessage setText:@"You've recieved a high score! Would you like to submit it?"];
    [self.submitMessage setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    [self.submitMessage setTextColor:[self colorWithHexString:@"ffffff"]];
    
    //set up makeHighScore
    self.makeHighScore = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.makeHighScore addTarget:self action:@selector(ok) forControlEvents:UIControlEventTouchUpInside];
    [self.makeHighScore setBackgroundImage:[UIImage imageNamed:@"okButton.png"] forState:UIControlStateNormal];
    self.makeHighScore.frame = CGRectMake(29, 80, 74, 44);
    
    
    //set up cancelSubmission
    self.cancelSubmission = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.cancelSubmission addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelSubmission setBackgroundImage:[UIImage imageNamed:@"cancelButton.png"] forState:UIControlStateNormal];
    self.cancelSubmission.frame = CGRectMake(149, 80, 74, 44);
    
    
    //add UI elements to submitScoreView
    [self.submitScoreView addSubview:self.submitMessage];
    [self.submitScoreView addSubview:self.makeHighScore];
    [self.submitScoreView addSubview:self.cancelSubmission];
    
    
    //add submitScoreView to EndGameViewController
    [self.view addSubview:self.submitScoreView];
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




- (IBAction)playAgain:(id)sender {
    if ([self.campaignType isEqualToString:@"albums"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"albumStrikes" toValue:0];
        [self.dba setStat:@"albumOuts" toValue:3];
        
    } else if([self.campaignType isEqualToString:@"artists"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"artistStrikes" toValue:0];
        [self.dba setStat:@"artistOuts" toValue:3];
        
    }

    [self performSegueWithIdentifier:@"playAgain" sender:self];
}

- (IBAction)mainMenu:(id)sender {
    
    //TODO: reset scores for strikes mode since they are no longer needed 
    
    if ([self.campaignType isEqualToString:@"albums"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"albumStrikes" toValue:0];
        [self.dba setStat:@"albumOuts" toValue:3];
        
    } else if([self.campaignType isEqualToString:@"artists"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"artistStrikes" toValue:0];
        [self.dba setStat:@"artistOuts" toValue:3];
        
    }
    
    [self performSegueWithIdentifier:@"mainMenu" sender:self];
    
}

- (void)cancel {
    
    //re enable EndGameViewController UI elements
    [self.replayButton setEnabled:TRUE];
    [self.mainMenuButton setEnabled:TRUE];
    
    //remove submitScoreView from EndGameViewController
    [self.submitScoreView removeFromSuperview];
    
    
    if ([self.campaignType isEqualToString:@"albums"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"albumStrikes" toValue:0];
        [self.dba setStat:@"albumOuts" toValue:3];
        
    } else if([self.campaignType isEqualToString:@"artists"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"artistStrikes" toValue:0];
        [self.dba setStat:@"artistOuts" toValue:3];
        
    }
}

- (void)ok {
    //set text for message
    [self.submitMessage setText:@"Please enter your name in the text field below."];
    
    //remove old UI elements
    [self.makeHighScore removeFromSuperview];
    [self.cancelSubmission removeFromSuperview];
    
    
    //set up nameField
    self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(38, 80, 177, 30)];
    [self.nameField setDelegate:self];
    self.nameField.borderStyle = UITextBorderStyleBezel;
    self.nameField.font = [UIFont systemFontOfSize:14.0];
    //self.nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.nameField.returnKeyType = UIReturnKeyDone;
    [self.nameField setTextAlignment:NSTextAlignmentCenter];
    [self.nameField setBackgroundColor:[self colorWithHexString:@"ffffff"]];
    
    //set up enterButton
    self.enterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.enterButton addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
    [self.enterButton setBackgroundImage:[UIImage imageNamed:@"enterButton.png"] forState:UIControlStateNormal];
    self.enterButton.frame = CGRectMake(95, 118, 63, 44);
    
    
    //add the new ones
    [self.submitScoreView addSubview:self.nameField];
    [self.submitScoreView addSubview:self.enterButton];
}

- (void)enter {
    
    [self.dba addHighscoreWithName:[self.nameField text] Score:_finalScore andMode:campaignType];
    //}
    
    
    //re enable EndGameViewController UI elements
    [self.replayButton setEnabled:TRUE];
    [self.mainMenuButton setEnabled:TRUE];
    
    //remove submitScoreView from EndGameViewController
    [self.submitScoreView removeFromSuperview];
    
    
    if ([self.campaignType isEqualToString:@"albums"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"albumStrikes" toValue:0];
        [self.dba setStat:@"albumOuts" toValue:3];
        
    } else if([self.campaignType isEqualToString:@"artists"]) {
        
        [self.dba resetStrikesInMode:self.campaignType];
        [self.dba setStat:@"artistStrikes" toValue:0];
        [self.dba setStat:@"artistOuts" toValue:3];
        
    }
}

@end
