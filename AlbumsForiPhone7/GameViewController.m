//
//  GameViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import "GameViewController.h"
#import "EndGameViewController.h"
#import "DBAccess.h"
#import "AlbumCover.h"
#import "ViewController.h"
#import "UIDevice-Hardware.h"

@interface GameViewController () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *coverDisplay;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *strikesLabel;
@property (nonatomic, strong) IBOutlet UILabel *outsLabel;
@property (nonatomic, strong) IBOutlet UILabel *guessPromptLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UIButton *noClueButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) UIImageView *guessCorrectIndicator;

//properties for iPhone 3.5 version
@property (nonatomic, strong) UIButton *viewLargeCover;
@property (nonatomic, strong) UIButton *viewSmallCover;

@property (nonatomic, strong) AlbumCover *choiceCover;

//add covers to chosenCovers & remove from covers
@property (nonatomic, strong) NSMutableArray *covers;
@property (nonatomic, strong) NSMutableArray *chosenCovers;

@property (nonatomic, strong) NSNumber *inFirstRound;

@property (nonatomic, strong) DBAccess *dba;


@end

@implementation GameViewController

@synthesize campaignType;

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
    NSLog(@"%@", campaignType);
    
    /*Option 1: no "I don't know" button*/
    //[self.submitButton setFrame:CGRectMake(123, 352, 75, 31)];
    
    /*Option 2: an "I don't know button"*/
    //[self.submitButton setFrame:CGRectMake(60, 352, 75, 31)];
    //[self.submitButton setFrame:CGRectMake(187, 352, 75, 31)];
    
    
    /*strikeGuessed Key
     0 = not guessed
     1 = guessed
     2 = wrong guess made
     3 = semi-wrong guess made*/
    
    
    self.inFirstRound = [[NSNumber alloc] initWithInt:0];
    
    //Database Setup
    self.dba = [[DBAccess alloc] init];
    
    
    //get random cover
    self.chosenCovers = [[NSMutableArray alloc] init];
    self.covers = [[NSMutableArray alloc] init];
    
    [self.covers addObject:[self.dba getRandomAlbumExcludingLastGame:self.campaignType]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    //set positions of UI Elements
    if (IS_IPHONE5) {
        
        [self.backButton setFrame:CGRectMake(14, 18, 72, 44)];
        [self.coverDisplay setFrame:CGRectMake(.5*self.view.frame.size.width - 100, 80, 200, 200)];
        [self.textField setFrame:CGRectMake(60, self.coverDisplay.frame.origin.y + self.coverDisplay.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18, 111, 21)];
        [self.strikesLabel setFrame:CGRectMake(179, 45, 111, 21)];
        [self.outsLabel setFrame:CGRectMake(94, 45, 62, 21)];
        
        if ([campaignType isEqualToString:@"artists"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Artist Name"];
        }
        else if([campaignType isEqualToString:@"albums"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Album Name"];
        }
        
        [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
        [self.submitButton setFrame:CGRectMake(60, self.guessPromptLabel.frame.origin.y + self.guessPromptLabel.frame.size.height + 8, 75, 31)];
        [self.noClueButton setFrame:CGRectMake(185, self.submitButton.frame.origin.y, 75, 31)];
        
    
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.backButton setFrame:CGRectMake(14, 18+20, 72, 44)];
        
        //make cover display into uibutton
        self.viewLargeCover = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.viewLargeCover setImage:[UIImage imageNamed:@"AlbumsCampaignButton.png"] forState:UIControlStateNormal];
        [self.coverDisplay removeFromSuperview];
        
        [self.viewLargeCover setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80+20, 120, 120)];
        [self.viewLargeCover addTarget:self action:@selector(setUpLargeCover) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.viewLargeCover];
        
        
        [self.textField setFrame:CGRectMake(60, self.viewLargeCover.frame.origin.y + self.viewLargeCover.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18+20, 111, 21)];
        [self.strikesLabel setFrame:CGRectMake(179, 45+20, 111, 21)];
        [self.outsLabel setFrame:CGRectMake(94, 45+20, 62, 21)];
        
        if ([campaignType isEqualToString:@"artists"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Artist Name"];
        }
        else if([campaignType isEqualToString:@"albums"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Album Name"];
        }
        
        [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
        [self.submitButton setFrame:CGRectMake(60, self.guessPromptLabel.frame.origin.y + self.guessPromptLabel.frame.size.height + 8, 75, 31)];
        [self.noClueButton setFrame:CGRectMake(185, self.submitButton.frame.origin.y, 75, 31)];
    
        
    } else {
        
        [self.backButton setFrame:CGRectMake(14, 18, 72, 44)];
        
        //make cover display into uibutton
        self.viewLargeCover = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.viewLargeCover setImage:[UIImage imageNamed:@"AlbumsCampaignButton.png"] forState:UIControlStateNormal];
        [self.coverDisplay removeFromSuperview];
        
        [self.viewLargeCover setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120)];
        [self.viewLargeCover addTarget:self action:@selector(setUpLargeCover) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.viewLargeCover];
        
      
        [self.textField setFrame:CGRectMake(60, self.viewLargeCover.frame.origin.y + self.viewLargeCover.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18, 111, 21)];
        [self.strikesLabel setFrame:CGRectMake(179, 45, 111, 21)];
        [self.outsLabel setFrame:CGRectMake(94, 45, 62, 21)];
        
        if ([campaignType isEqualToString:@"artists"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Artist Name"];
        }
        else if([campaignType isEqualToString:@"albums"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Album Name"];
        }
        
        [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
        [self.submitButton setFrame:CGRectMake(60, self.guessPromptLabel.frame.origin.y + self.guessPromptLabel.frame.size.height + 8, 75, 31)];
        [self.noClueButton setFrame:CGRectMake(185, self.submitButton.frame.origin.y, 75, 31)];
        
    }
    
    //TODO: 1. use data from progress & stats tables to perform inital set up.
    

    //NSLog(@"%d", [self.covers count]);
    //self.initialRand = [[NSNumber alloc] initWithInt: arc4random() % 250];
    //self.covers = [self.dba getAlbumsAtAlbumID:[self.initialRand intValue] withLimit:1];
    
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //set text color
    [self.scoreLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.strikesLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.guessPromptLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.outsLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    
    
    AlbumCover *cover = [self.covers objectAtIndex:0];
    
    //TODO: Check strikeGuessed value against randomID. select new random if already guessed

    //self.covers = [self.dba getAlbums];

    //setup guessCorrectIndicator
    self.guessCorrectIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width + 10, self.textField.frame.origin.y, 30, 30)];
    
    if ([self.campaignType isEqualToString:@"albums"]) {
        if([cover.albumStrikesGuessed intValue] == 0) {
            [self.guessCorrectIndicator setHidden:YES];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([cover.albumStrikesGuessed intValue] == 2) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
        }
        else if([cover.albumStrikesGuessed intValue] == 3) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
        }
        
        
    }
    else if ([self.campaignType isEqualToString:@"artists"]) {
        if([cover.artistStrikesGuessed intValue] == 0) {
            [self.guessCorrectIndicator setHidden:YES];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([cover.artistStrikesGuessed intValue] == 2) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
        }
        else if([cover.artistStrikesGuessed intValue] == 3) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
        }
        
    }
    
    [self.view addSubview:self.guessCorrectIndicator];
    
    
    //set values of score & strikes variables
    if ([self.campaignType isEqualToString:@"albums"]) {
        score = [self.dba getStat:@"albumStrikes"];
        strikes = [cover.albumStrikesLeft intValue];
        outs = [self.dba getStat:@"albumOuts"];
    }
    else if ([self.campaignType isEqualToString:@"artists"]) {
        score = [self.dba getStat:@"artistStrikes"];
        strikes = [cover.artistStrikesLeft intValue];
        outs = [self.dba getStat:@"artistOuts"];
    }
    
    
    //set values of labels
    [self.strikesLabel setText:[NSString stringWithFormat:@"Strikes: %d", strikes]];
    [self.outsLabel setText:[NSString stringWithFormat:@"Outs: %d", outs]];
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
    
    
    maxScore = 100 * 250;
    
    
    int playSounds = [self.dba getSetting:@"playSounds"];
    NSLog(@"playSounds = %d", playSounds);
    
    [self performSelectorOnMainThread:@selector(cycleAlbumCovers) withObject:nil waitUntilDone:NO];

    
}

-(void) backgroundSetUpCovers {
    AlbumCover *cover = [self.covers objectAtIndex:0];
    NSNumber *ID = cover.albumID;
    int albumID = [ID intValue];
    self.covers = [self.dba getAlbumsExcludingLastGame:self.campaignType andAlbumID:albumID];


}


- (void)cycleAlbumCovers {
    
    
    [self.submitButton setEnabled:TRUE];
    [self.noClueButton setEnabled:TRUE];
    
    
    if ([self.covers count] == 0) {
        //go to the you win screen
        [self performSegueWithIdentifier:@"youWon" sender:self];
    } else {
        if (outs == 0) {
            
            //TODO reset strikes and outs data for next game
            
            //go to the game over screen
            [self performSegueWithIdentifier:@"youLost" sender:self];
        }
        else {
            //randomly choose an album cover from covers
            int choiceIndex = arc4random() % [self.covers count];
            
            self.choiceCover = [self.covers objectAtIndex:choiceIndex];
            //NSLog(@"%d", [self.covers count]);
            
            
            
            //hide guessCorrectIndicator
            [self.guessCorrectIndicator setHidden:YES];
            if ([self.campaignType isEqualToString:@"albums"]) {
                if([self.choiceCover.albumStrikesGuessed intValue] == 0) {
                    [self.guessCorrectIndicator setHidden:YES];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
                }
                else if([self.choiceCover.albumStrikesGuessed intValue] == 2) {
                    [self.guessCorrectIndicator setHidden:NO];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
                }
                else if([self.choiceCover.albumStrikesGuessed intValue] == 3) {
                    [self.guessCorrectIndicator setHidden:NO];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
                }
                
                
            }
            else if ([self.campaignType isEqualToString:@"artists"]) {
                if([self.choiceCover.artistStrikesGuessed intValue] == 0) {
                    [self.guessCorrectIndicator setHidden:YES];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
                }
                else if([self.choiceCover.artistStrikesGuessed intValue] == 2) {
                    [self.guessCorrectIndicator setHidden:NO];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
                }
                else if([self.choiceCover.artistStrikesGuessed intValue] == 3) {
                    [self.guessCorrectIndicator setHidden:NO];
                    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
                }
                
            }
            
            
            //set values of score & strikes variables
            if ([self.campaignType isEqualToString:@"albums"]) {
                score = [self.dba getStat:@"albumStrikes"];
                strikes = [self.choiceCover.albumStrikesLeft intValue];
                outs = [self.dba getStat:@"albumOuts"];
            }
            else if ([self.campaignType isEqualToString:@"artists"]) {
                score = [self.dba getStat:@"artistStrikes"];
                strikes = [self.choiceCover.artistStrikesLeft intValue];
                outs = [self.dba getStat:@"artistOuts"];
            }
            
            
            //set values of labels
            [self.strikesLabel setText:[NSString stringWithFormat:@"Strikes: %d", strikes]];
            [self.outsLabel setText:[NSString stringWithFormat:@"Outs: %d", outs]];
            [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
            
            
            //update the displayed cover
            if (IS_IPHONE5) {
                self.coverDisplay.image = [self.choiceCover questionCover];
            } else {
                [self.coverDisplay removeFromSuperview];
                [self.view addSubview:self.viewLargeCover];
                [self.viewLargeCover setImage:[self.choiceCover questionCover] forState:UIControlStateNormal];
            }
            
            
            //clear the text field
            [self.textField setText:@""];
            

            //NSLog(@"%lu", (unsigned long)[self.covers count]);
            if([self.covers count] == 1 && [self.inFirstRound intValue] == 0) {
                [NSThread detachNewThreadSelector:@selector(backgroundSetUpCovers) toTarget:self withObject:nil];
                self.inFirstRound = [NSNumber numberWithInt:1];
            }
            else {
                
               NSLog(@"%lu", (unsigned long)[self.covers count]);
               NSLog(@"%lu", (unsigned long)[self.chosenCovers count]);
            }
            
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*For iPhone 3.5 inch retina*/
-(void)setUpLargeCover {
    //setup uiimageview
    
    [self.viewLargeCover removeFromSuperview];
    
    int idVal = [[self.choiceCover albumID] intValue];
    NSLog(@"%d", idVal);
    self.coverDisplay.frame = CGRectMake(.5*self.view.frame.size.width - 100, 80, 200, 200);
    self.coverDisplay.image = [self.dba getLargeCoverFileAtAlbumID:idVal];

    //[self.coverDisplayLarge setHidden:NO];
    [self.view addSubview:self.coverDisplay];
    
    
    //setup uibutton
    self.viewSmallCover = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.viewSmallCover setImage:[UIImage imageNamed:@"CloseButton.png"] forState:UIControlStateNormal];
    [self.viewSmallCover setFrame:CGRectMake(.5*self.view.frame.size.width - 125, 70, 50, 31)];
    [self.viewSmallCover addTarget:self action:@selector(backToSmallCover) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewSmallCover];
}

-(void)backToSmallCover {
    
    [self.viewSmallCover removeFromSuperview];
    [self.coverDisplay removeFromSuperview];
    
    [self.view addSubview:self.viewLargeCover];
    
}


/*
 * Back button for going to main menu. Keep it simple for now.
 */

- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"main" sender:self];

}



/*
 * Submit button for checking guesses against the actual album Name
 * will update status label to reflect whether guess is correct or not
 */
- (IBAction)makeGuess:(id)sender {
    
    //get settings
    int playSounds = [self.dba getSetting:@"playSounds"];
    
    
    BOOL coverGuessed = NO;
    BOOL partiallyGuessed = NO;
    
    
    if ([campaignType isEqualToString:@"albums"]) {
        

        
        for (int i=0; i<[self.choiceCover.answers count]; i++) {
            
            if ([self.choiceCover.answers[i] caseInsensitiveCompare:self.textField.text] == NSOrderedSame) {
                //guesses are the same
                coverGuessed = YES;
                NSLog(@"%@", self.choiceCover.answers[i]);
            } else {
                
                
                
                int matchedCharsLength = 0;
                
                NSString *guess = [self.textField.text lowercaseString];
                NSString *answer = [self.choiceCover.answers[i] lowercaseString];
                
                
                
                int guessLength = (int)[guess length]-1;
                int answerLength = (int)[answer length]-1;
                
                
                if (guessLength <= answerLength) {
                    
                    //check if guess matches a substring of the answer
                    for (int j=0; j<guessLength; j++) {
                        
                        NSLog(@"Range: %d to %d", j, j+1);
                        
                        if([guess characterAtIndex:j] == [answer characterAtIndex:j]) {
                            
                            matchedCharsLength++;
                            NSLog(@"Match %d characters. Guesslength = %d", matchedCharsLength, guessLength);
                            //NSLog(@"\"%@\" doesn't match \"%@\"", guess, answer);
                        } else
                        {
                            if (([guess characterAtIndex:j] == [@"'" characterAtIndex:0] && [answer characterAtIndex:j] == [@"’" characterAtIndex:0]) ||
                                ([guess characterAtIndex:j] == [@"\"" characterAtIndex:0] && [answer characterAtIndex:j] == [@"”" characterAtIndex:0]) ) {
                                
                                matchedCharsLength++;
                            }
                            
                        }
                        
                        
                    }
                    
                    if (guessLength == matchedCharsLength) {
                        if(matchedCharsLength == answerLength && answerLength == guessLength) {
                            //if we're here, this is actually a match
                            coverGuessed = YES;
                            NSLog(@"%@", self.choiceCover.answers[i]);
                            
                        } else {
                            //if we're here, we have a partial match
                            partiallyGuessed = YES;
                        }
                        
                    }
                }
            }
        }

        
    }
    else if([campaignType isEqualToString:@"artists"]) {
        
        for (int i=0; i<[self.choiceCover.artists count]; i++) {
            
            if ([self.choiceCover.artists[i] caseInsensitiveCompare:self.textField.text] == NSOrderedSame) {
                //guesses are the same
                coverGuessed = YES;
                NSLog(@"%@", self.choiceCover.artists[i]);
            } else {
                
                
                
                int matchedCharsLength = 0;
                
                NSString *guess = [self.textField.text lowercaseString];
                NSString *answer = [self.choiceCover.artists[i] lowercaseString];
                
                
                
                int guessLength = (int)[guess length]-1;
                int answerLength = (int)[answer length]-1;
                
                
                if (guessLength <= answerLength) {
                    
                    //check if guess matches a substring of the answer
                    for (int j=0; j<guessLength; j++) {
                        
                        NSLog(@"Range: %d to %d", j, j+1);
                        
                        if([guess characterAtIndex:j] == [answer characterAtIndex:j]) {
                            
                            matchedCharsLength++;
                            NSLog(@"Match %d characters. Guesslength = %d", matchedCharsLength, guessLength);
                            //NSLog(@"\"%@\" doesn't match \"%@\"", guess, answer);
                        }
                        else {
                            if (([guess characterAtIndex:j] == [@"'" characterAtIndex:0] && [answer characterAtIndex:j] == [@"’" characterAtIndex:0]) ||
                                ([guess characterAtIndex:j] == [@"\"" characterAtIndex:0] && [answer characterAtIndex:j] == [@"”" characterAtIndex:0]) ) {
                                
                                matchedCharsLength++;
                            }
                            
                        }
                        
                        
                    }
                    
                    if (guessLength == matchedCharsLength) {
                        if(matchedCharsLength == answerLength && answerLength == guessLength) {
                            //if we're here, this is actually a match
                            coverGuessed = YES;
                            NSLog(@"%@", self.choiceCover.artists[i]);
                            
                        } else {
                            //if we're here, we have a partial match
                            partiallyGuessed = YES;
                        
                        }
                        
                    }
                }
            }
        }

        
    }
    
    
    
    
    
    
    if (coverGuessed) {
        
        //update last guess outcome value
        [self.dba updateStrikeGuessedAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:1];
        
        if ([campaignType isEqualToString:@"albums"]) {
            [self.choiceCover setAlbumStrikesGuessed:[NSNumber numberWithInt:1]];
        }
        else if([campaignType isEqualToString:@"artists"]) {
            [self.choiceCover setArtistStrikesGuessed:[NSNumber numberWithInt:1]];
        }
        
        
        //finish setting up guessCorrectIndicator
        [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        [self.guessCorrectIndicator setHidden:NO];
        
        //if sound effects are on
        if (playSounds == 1) {
            
            //play CorrectGuessSound.caf audio file
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            CFURLRef soundFileURLREF;
            soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"CorrectGuessSound", CFSTR ("caf"), NULL);
            UInt32 soundID;
            AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
            AudioServicesPlaySystemSound(soundID);
            CFRelease(soundFileURLREF);
        }
        
        
        
        [self performSelector:@selector(showAnswer) withObject:nil afterDelay:0.2];
    }
    else if(partiallyGuessed) {

        //update last guess outcome value
        [self.dba updateStrikeGuessedAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:3];
        if ([campaignType isEqualToString:@"albums"]) {
            [self.choiceCover setAlbumStrikesGuessed:[NSNumber numberWithInt:3]];
        }
        else if([campaignType isEqualToString:@"artists"]) {
            [self.choiceCover setArtistStrikesGuessed:[NSNumber numberWithInt:3]];
        }
        
        //Strikes: 3
        NSLog(@"%d %d", strikes, outs);
        if (strikes!=0) {
            strikes--;
            
            //update strikes
            [self.dba updateStrikesLeftAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:strikes];
            if ([campaignType isEqualToString:@"albums"]) {
                [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:strikes]];
            }
            else if([campaignType isEqualToString:@"artists"]) {
                [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:strikes]];
            }
            
        }
        if(strikes==0){
            outs--;
            
            //update outs
            if ([campaignType isEqualToString:@"albums"]) {
                [self.dba setStat:@"albumOuts" toValue:outs];
            }
            else if([campaignType isEqualToString:@"artists"]) {
                [self.dba setStat:@"artistOuts" toValue:outs];
            }
        }
        
        
        //modify max album score
        int scoreIncrement = 0;
        if ([campaignType isEqualToString:@"albums"]) {
            scoreIncrement = [self.choiceCover.albumStrikesScore intValue];
            scoreIncrement = scoreIncrement - 15;
            [self.choiceCover setAlbumStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
        }
        else if([campaignType isEqualToString:@"artists"]) {
            scoreIncrement = [self.choiceCover.artistStrikesScore intValue];
            scoreIncrement = scoreIncrement - 15;
            [self.choiceCover setArtistStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
        }
        [self.dba updateStrikeMaxScoreAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:scoreIncrement];

        
        //finish setting up guessCorrectIndicator
        [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
        [self.guessCorrectIndicator setHidden:NO];
        
        //if sound effects are on
        if(playSounds == 1) {
            
            //play Wrong.caf audio file
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            CFURLRef soundFileURLREF;
            soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"Wrong", CFSTR ("caf"), NULL);
            UInt32 soundID;
            AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
            AudioServicesPlaySystemSound(soundID);
            CFRelease(soundFileURLREF);
        }
        
        if(strikes ==0) {
            [self showAnswer];
            //strikes = 3;
        }
        [self.strikesLabel setText:[NSString stringWithFormat:@"Strikes: %d", strikes]];
        [self.outsLabel setText:[NSString stringWithFormat:@"Outs: %d", outs]];
        
    }
    else {
        
        //update last guess outcome value
        [self.dba updateStrikeGuessedAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:2];
        if ([campaignType isEqualToString:@"albums"]) {
            [self.choiceCover setAlbumStrikesGuessed:[NSNumber numberWithInt:2]];
        }
        else if([campaignType isEqualToString:@"artists"]) {
            [self.choiceCover setArtistStrikesGuessed:[NSNumber numberWithInt:2]];
        }
        
        //Strikes: 3
        NSLog(@"%d %d", strikes, outs);
        if (strikes!=0) {
            strikes--;
            
            //update strikes
            [self.dba updateStrikesLeftAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:strikes];
            if ([campaignType isEqualToString:@"albums"]) {
                [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:strikes]];
            }
            else if([campaignType isEqualToString:@"artists"]) {
                [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:strikes]];
            }
            
        }
        if(strikes == 0){
            outs--;
            
            //update outs
            if ([campaignType isEqualToString:@"albums"]) {
                [self.dba setStat:@"albumOuts" toValue:outs];
            }
            else if([campaignType isEqualToString:@"artists"]) {
                [self.dba setStat:@"artistOuts" toValue:outs];
            }
        }
        
        
        //modify max album score
        int scoreIncrement = 0;
        if ([campaignType isEqualToString:@"albums"]) {
            scoreIncrement = [self.choiceCover.albumStrikesScore intValue];
            scoreIncrement = scoreIncrement - 33;
            [self.choiceCover setAlbumStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
        }
        else if([campaignType isEqualToString:@"artists"]) {
            scoreIncrement = [self.choiceCover.artistStrikesScore intValue];
            scoreIncrement = scoreIncrement - 33;
            [self.choiceCover setArtistStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
        }
        [self.dba updateStrikeMaxScoreAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:scoreIncrement];

        
        //finish setting up guessCorrectIndicator
        [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
        [self.guessCorrectIndicator setHidden:NO];
        
        //if sound effects are on
        if(playSounds == 1) {
            
            //play Wrong.caf audio file
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            CFURLRef soundFileURLREF;
            soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"Wrong", CFSTR ("caf"), NULL);
            UInt32 soundID;
            AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
            AudioServicesPlaySystemSound(soundID);
            CFRelease(soundFileURLREF);
        }

        if(strikes == 0) {
            if (outs !=0) {
                strikes = 3;
            }
            [self showAnswer];
        }
        [self.strikesLabel setText:[NSString stringWithFormat:@"Strikes: %d", strikes]];
        [self.outsLabel setText:[NSString stringWithFormat:@"Outs: %d", outs]];
    
    }
}

- (IBAction)noIdea:(id)sender {
    
    //update strikes
    [self.dba updateStrikesLeftAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:0];
    if ([campaignType isEqualToString:@"albums"]) {
        [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:0]];
    }
    else if([campaignType isEqualToString:@"artists"]) {
        [self.choiceCover setAlbumStrikesLeft:[NSNumber numberWithInt:0]];
    }
    
    //Strikes: 3
    outs--;
    
    //update outs
    if ([campaignType isEqualToString:@"albums"]) {
        [self.dba setStat:@"albumOuts" toValue:outs];
    }
    else if([campaignType isEqualToString:@"artists"]) {
        [self.dba setStat:@"artistOuts" toValue:outs];
    }
    [self.outsLabel setText:[NSString stringWithFormat:@"Outs: %d", outs]];
    
    if (outs==0) {
        [self.strikesLabel setText:[NSString stringWithFormat:@"Strikes: 0"]];
    }
    
    
    //finish setting up guessCorrectIndicator
    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
    [self.guessCorrectIndicator setHidden:NO];
    
    
    //modify max album score
    int scoreIncrement = 0;
    if ([campaignType isEqualToString:@"albums"]) {
        scoreIncrement = [self.choiceCover.albumStrikesScore intValue];
        scoreIncrement = scoreIncrement - 50;
        [self.choiceCover setAlbumStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
    }
    else if([campaignType isEqualToString:@"artists"]) {
        scoreIncrement = [self.choiceCover.artistStrikesScore intValue];
        scoreIncrement = scoreIncrement - 50;
        [self.choiceCover setArtistStrikesScore:[NSNumber numberWithInt:scoreIncrement]];
    }
    [self.dba updateStrikeMaxScoreAtAlbumID:[self.choiceCover.albumID intValue] inMode:campaignType toValue:scoreIncrement];

    
    int playSounds = [self.dba getSetting:@"playSounds"];
    
    //if sound effects are on
    if(playSounds == 1) {
        
        //play Wrong.caf audio file
        CFBundleRef mainBundle = CFBundleGetMainBundle();
        CFURLRef soundFileURLREF;
        soundFileURLREF = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"Wrong", CFSTR ("caf"), NULL);
        UInt32 soundID;
        AudioServicesCreateSystemSoundID(soundFileURLREF, &soundID);
        AudioServicesPlaySystemSound(soundID);
        CFRelease(soundFileURLREF);
        //[soundID release];
    }
    
    
    [self showAnswer];
    
    
}


-(void)showAnswer {
    

    //display full album cover
    self.coverDisplay.image = [self.choiceCover answerCover];
    if (IS_IPHONE5) {
        self.coverDisplay.image = [self.choiceCover answerCover];
    } else {
        [self.viewLargeCover removeFromSuperview];
        
        self.coverDisplay.frame = CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120);
        self.coverDisplay.image = [self.choiceCover answerCover];
        
        //[self.coverDisplayLarge setHidden:NO];
        [self.view addSubview:self.coverDisplay];
    }
    
    //update score increment
    int scoreIncrement =0;
    if ([campaignType isEqualToString:@"albums"]) {
        scoreIncrement = [self.choiceCover.albumStrikesScore intValue];
    }
    else if([campaignType isEqualToString:@"artists"]) {
        scoreIncrement = [self.choiceCover.artistStrikesScore intValue];
    }
    
    //Score:  0
    score = score + scoreIncrement;
    
    //update database score
    if ([campaignType isEqualToString:@"albums"]) {
        [self.dba setStat:@"albumStrikes" toValue:score];
        
    }
    else if([campaignType isEqualToString:@"artists"]) {
        [self.dba setStat:@"artistStrikes" toValue:score];
    }
    
    //update score label
    [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", score]];
    
    
    //modify arrays
    [self.chosenCovers addObject:self.choiceCover];
    [self.covers removeObject:self.choiceCover];
    
    
    //change state of submit button
    [self.submitButton setEnabled:FALSE];
    [self.noClueButton setEnabled:FALSE];
    
    
    //pause
    //sleep(2.5);
    //[self cycleAlbumCovers];
    
    
    [self performSelector:@selector(cycleAlbumCovers) withObject:nil afterDelay:2.5];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"youWon"]) {
        
        NSString *labelMessage = @"You Win!";
        EndGameViewController *endOfGame = [segue destinationViewController];
        endOfGame.labelMessage = labelMessage;
        endOfGame.finalScore = score;
        endOfGame.campaignType = self.campaignType;

        
    } else if([segue.identifier isEqualToString:@"youLost"]) {
        
        NSString *labelMessage = @"Game Over";
        EndGameViewController *endOfGame = [segue destinationViewController];
        endOfGame.labelMessage = labelMessage;
        endOfGame.finalScore = score;
        endOfGame.campaignType = self.campaignType;
        
        
    } else if([segue.identifier isEqualToString:@"main"]) {
        ViewController *main = [segue destinationViewController];
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

#pragma mark - UITextFieldDelegate methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}




//database test
/*int marker= 0;
 NSString *testOutput = [[NSString alloc]init];
 
 for (AlbumCover *c in covers) {
 testOutput = [testOutput stringByAppendingFormat:@"Cover %d answers: ", marker];
 
 for (int i=0; i<[c.answers count]; i++) {
 if (i != ([c.answers count] -1)) {
 testOutput = [testOutput stringByAppendingFormat:@"%@, ", [c.answers objectAtIndex:i]];
 }
 else {
 testOutput = [testOutput stringByAppendingFormat:@"%@ ", [c.answers objectAtIndex:i]];
 }
 
 
 
 }
 
 testOutput = [testOutput stringByAppendingString:@"\n"];
 marker++;
 }
 
 NSLog(@"%@", testOutput);*/

@end
