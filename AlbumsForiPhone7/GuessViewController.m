//
//  GuessViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/15/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "GuessViewController.h"
#import "DBAccess.h"
#import "AlbumCover.h"
#import "LevelViewController.h"
#import "UIDevice-Hardware.h"

@interface GuessViewController () <UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIImageView *coverDisplay;
@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *hintsLabel;
@property (nonatomic, strong) IBOutlet UILabel *guessPromptLabel;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *submitButton;
@property (nonatomic, strong) IBOutlet UIButton *noClueButton;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *showHintButton;
@property (nonatomic, strong) UIImageView *guessCorrectIndicator;
@property (nonatomic, strong) UIScrollView *hintView;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *statusLabel;

//properties for iPhone 3.5 version
@property (nonatomic, strong) UIButton *viewLargeCover;
@property (nonatomic, strong) UIButton *viewSmallCover;


@property (nonatomic, strong) DBAccess *dba;
@property (nonatomic, strong) AlbumCover *selectedCover;


@end

@implementation GuessViewController
@synthesize albumID, score, levelSelected, campaignType;

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
    
    NSLog(@"%@", self.campaignType);
    
    //set up database
    self.dba = [[DBAccess alloc] init];
    
    //set up selected cover
    self.selectedCover = [self.dba getAlbumAtAlbumID:[self.albumID intValue]];
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];

    //set text color
    [self.scoreLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.guessPromptLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [self.hintsLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    
    //set up uitextview
    self.hintView = [[UIScrollView alloc] init];
    [self.hintView setDelegate:self];
    [self.hintView setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    [self.hintView setHidden:YES];
    //[self.hintView setFont:[UIFont boldSystemFontOfSize:17]];
    
    //set up hintLabel
    self.hintLabel = [[UILabel alloc] init];
    [self.hintLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.hintLabel setNumberOfLines:0];
    [self.hintLabel setTextAlignment:NSTextAlignmentCenter];
    [self.hintLabel setTextColor:[self colorWithHexString:@"ffffff"]];

    //set up status label
    self.statusLabel = [[UILabel alloc] init];
    [self.statusLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.statusLabel setNumberOfLines:0];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.statusLabel setBackgroundColor:[self colorWithHexString:@"00234b"]];
    [self.statusLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    //set positions of UI Elements
    if (IS_IPHONE5) {
        
        [self.backButton setFrame:CGRectMake(14, 18, 72, 44)];
        [self.coverDisplay setFrame:CGRectMake(.5*self.view.frame.size.width - 100, 80, 200, 200)];

        [self.hintView setFrame:CGRectMake(.5*self.view.frame.size.width -100, 80, 200, 200)];
        [self.hintLabel setFrame:CGRectMake(0, 0, 200, 200)];
        [self.view addSubview:self.hintView];

        [self.textField setFrame:CGRectMake(60, self.coverDisplay.frame.origin.y + self.coverDisplay.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18, 111, 21)];
        [self.hintsLabel setFrame:CGRectMake(179, 45, 111, 21)];
        
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
        
        [self.showHintButton setFrame:CGRectMake(.5*self.view.frame.size.width-25, self.view.frame.size.height-70, 50, 50)];
        [self.statusLabel setFrame:CGRectMake(60, self.submitButton.frame.origin.y + self.submitButton.frame.size.height + 8, 200, 60)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.backButton setFrame:CGRectMake(14, 18+20, 72, 44)];
        //[self.coverDisplay setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120)];
        //make cover display into uibutton
        self.viewLargeCover = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.viewLargeCover setImage:[UIImage imageNamed:@"AlbumsCampaignButton.png"] forState:UIControlStateNormal];
        [self.coverDisplay removeFromSuperview];
        
        [self.viewLargeCover setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80+20, 120, 120)];
        [self.viewLargeCover addTarget:self action:@selector(setUpLargeCover) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.viewLargeCover];
        
        [self.hintView setFrame:CGRectMake(.5*self.view.frame.size.width -60, 80+20, 120, 120)];
        [self.hintLabel setFrame:CGRectMake(0, 0, 120, 120)];
        [self.view addSubview:self.hintView];
        
        [self.textField setFrame:CGRectMake(60, self.viewLargeCover.frame.origin.y + self.viewLargeCover.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18+20, 111, 21)];
        [self.hintsLabel setFrame:CGRectMake(179, 45+20, 111, 21)];
        
        if ([campaignType isEqualToString:@"artists"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Artist Name"];
        }
        else if([campaignType isEqualToString:@"albums"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Album Name"];
        }
        
        
        [self.submitButton setFrame:CGRectMake(60, self.guessPromptLabel.frame.origin.y + self.guessPromptLabel.frame.size.height + 8, 75, 31)];
        [self.noClueButton setFrame:CGRectMake(185, self.submitButton.frame.origin.y, 75, 31)];
        
        [self.showHintButton setFrame:CGRectMake(.5*self.view.frame.size.width-25, self.view.frame.size.height-70, 50, 50)];
        [self.statusLabel setFrame:CGRectMake(60, self.submitButton.frame.origin.y + self.submitButton.frame.size.height + 8, 200, 60)];
    
    } else {
        
        [self.backButton setFrame:CGRectMake(14, 18, 72, 44)];
        //[self.coverDisplay setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120)];
        //make cover display into uibutton
        self.viewLargeCover = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.viewLargeCover setImage:[UIImage imageNamed:@"AlbumsCampaignButton.png"] forState:UIControlStateNormal];
        [self.coverDisplay removeFromSuperview];
        
        [self.viewLargeCover setFrame:CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120)];
        [self.viewLargeCover addTarget:self action:@selector(setUpLargeCover) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.viewLargeCover];
        
        [self.hintView setFrame:CGRectMake(.5*self.view.frame.size.width -60, 80, 120, 120)];
        [self.hintLabel setFrame:CGRectMake(0, 0, 120, 120)];
        [self.view addSubview:self.hintView];
        
        [self.textField setFrame:CGRectMake(60, self.viewLargeCover.frame.origin.y + self.viewLargeCover.frame.size.width + 14, 200, 30)];
        [self.scoreLabel setFrame:CGRectMake(179, 18, 111, 21)];
        [self.hintsLabel setFrame:CGRectMake(179, 45, 111, 21)];
        
        if ([campaignType isEqualToString:@"artists"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Artist Name"];
        }
        else if([campaignType isEqualToString:@"albums"]) {
            [self.guessPromptLabel setFrame:CGRectMake(60, self.textField.frame.origin.y + self.textField.frame.size.height + 11, 200, 21)];
            [self.guessPromptLabel setText:@"Guess the Album Name"];
        }

       
        [self.submitButton setFrame:CGRectMake(60, self.guessPromptLabel.frame.origin.y + self.guessPromptLabel.frame.size.height + 8, 75, 31)];
        [self.noClueButton setFrame:CGRectMake(185, self.submitButton.frame.origin.y, 75, 31)];
        
        [self.showHintButton setFrame:CGRectMake(.5*self.view.frame.size.width-25, self.view.frame.size.height-70, 50, 50)];
        [self.statusLabel setFrame:CGRectMake(60, self.submitButton.frame.origin.y + self.submitButton.frame.size.height + 8, 200, 60)];
    }
    
    //set label text
    if ([campaignType isEqualToString:@"artists"]) {
        [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", [self.dba getStat:@"artistLevels"]]];
    
    }
    else if ([campaignType isEqualToString:@"albums"]) {
        [self.scoreLabel setText:[NSString stringWithFormat:@"Score: %d", [self.dba getStat:@"albumLevelss"]]];
    }
    [self.hintsLabel setText:[NSString stringWithFormat:@"Hints: %d", [self.dba getStat:@"totalHints"]]];
    
    //setup guessCorrectIndicator
    self.guessCorrectIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(self.textField.frame.origin.x + self.textField.frame.size.width + 10, self.textField.frame.origin.y, 30, 30)];
    [self.guessCorrectIndicator setHidden:YES];
    [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
    [self.view addSubview:self.guessCorrectIndicator];
    
    
    if ([self.campaignType isEqualToString:@"albums"]) {
        if([self.selectedCover.albumLevelsGuessed intValue] == 0) {
            [self.guessCorrectIndicator setHidden:YES];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([self.selectedCover.albumLevelsGuessed intValue] == 1) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([self.selectedCover.albumLevelsGuessed intValue] == 2) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
        }
        else if([self.selectedCover.albumLevelsGuessed intValue] == 3) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
        }
        
        
    }
    else if ([self.campaignType isEqualToString:@"artists"]) {
        if([self.selectedCover.artistLevelsGuessed intValue] == 0) {
            [self.guessCorrectIndicator setHidden:YES];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([self.selectedCover.artistLevelsGuessed intValue] == 1) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        }
        else if([self.selectedCover.artistLevelsGuessed intValue] == 2) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
        }
        else if([self.selectedCover.artistLevelsGuessed intValue] == 3) {
            [self.guessCorrectIndicator setHidden:NO];
            [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
        }
        
    }

    //update the displayed cover
    if (IS_IPHONE5) {
        self.coverDisplay.image = [self.selectedCover questionCover];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.viewLargeCover setImage:[self.selectedCover questionCover] forState:UIControlStateNormal];
    } else {
        [self.viewLargeCover setImage:[self.selectedCover questionCover] forState:UIControlStateNormal];
    }
    //self.coverDisplay.image = [self.selectedCover questionCover];
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %i", [self.score intValue]];
    
    strikes = 5;
    
    
    //finsh setting up hintView
    if ([campaignType isEqualToString:@"artists"]) {
        self.hintLabel.text = [self.selectedCover artistHint];
        [self.hintView addSubview:self.hintLabel];
    }
    else if([campaignType isEqualToString:@"albums"]) {
        self.hintLabel.text = [self.selectedCover albumHint];
        [self.hintView addSubview:self.hintLabel];
    }
    
    NSLog(@"%@", [self.hintLabel.text substringWithRange:NSMakeRange(0, 2)]);
     NSLog(@"%@", [self.hintLabel.text substringWithRange:NSMakeRange(0, 3)]);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"back"]) {
        
        //update the database here
        
        
        
        //pass data to view
        LevelViewController *curLevel = [segue destinationViewController];
        curLevel.campaignType = self.campaignType;
        curLevel.levelSelected = self.levelSelected;
        curLevel.score = self.score;
    }
    
}


/*For iPhone 3.5 inch retina*/
-(void)setUpLargeCover {
    //setup uiimageview
    
    [self.viewLargeCover removeFromSuperview];
    
    //int idVal = [[self.choiceCover albumID] intValue];
    //NSLog(@"%d", idVal);
    self.coverDisplay.frame = CGRectMake(.5*self.view.frame.size.width - 100, 80, 200, 200);
    self.coverDisplay.image = [self.dba getLargeCoverFileAtAlbumID:[self.albumID intValue]];
    
    //[self.coverDisplayLarge setHidden:NO];
    [self.view addSubview:self.coverDisplay];
    
    
    //setup uibutton
    self.viewSmallCover = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.viewSmallCover setImage:[UIImage imageNamed:@"CloseButton.png"] forState:UIControlStateNormal];
    [self.viewSmallCover setFrame:CGRectMake(.5*self.view.frame.size.width - 125, 70, 50, 31)];
    [self.viewSmallCover addTarget:self action:@selector(backToSmallCover) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewSmallCover];
    
    [self.showHintButton setHidden:YES];
}

-(void)backToSmallCover {
    
    [self.viewSmallCover removeFromSuperview];
    [self.coverDisplay removeFromSuperview];
    
    [self.view addSubview:self.viewLargeCover];
    [self.showHintButton setHidden:NO];
    
}


- (IBAction)makeGuess:(id)sender {
    //get settings
    int playSounds = [self.dba getSetting:@"playSounds"];
    
    
    BOOL coverGuessed = NO;
    BOOL partiallyGuessed = NO;

    if ([campaignType isEqualToString:@"albums"]) {
        
        for (int i=0; i<[self.selectedCover.answers count]; i++) {
            
            if ([self.selectedCover.answers[i] caseInsensitiveCompare:self.textField.text] == NSOrderedSame) {
                //guesses are the same
                coverGuessed = YES;
                NSLog(@"%@", self.selectedCover.answers[i]);
            } else {
                
                
                
                int matchedCharsLength = 0;
                
                NSString *guess = [self.textField.text lowercaseString];
                NSString *answer = [self.selectedCover.answers[i] lowercaseString];
                
                
                
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
                            NSLog(@"%@", self.selectedCover.answers[i]);
                            
                        } else {
                            //if we're here, we have a partial match
                            partiallyGuessed = YES;
                        }
                        
                    }
                }
            }
        }

        
    }
    else if ([campaignType isEqualToString:@"artists"]){
        
        for (int i=0; i<[self.selectedCover.artists count]; i++) {
            
            if ([self.selectedCover.artists[i] caseInsensitiveCompare:self.textField.text] == NSOrderedSame) {
                //guesses are the same
                coverGuessed = YES;
                NSLog(@"%@", self.selectedCover.artists[i]);
            } else {
                
                
                
                int matchedCharsLength = 0;
                
                NSString *guess = [self.textField.text lowercaseString];
                NSString *answer = [self.selectedCover.artists[i] lowercaseString];
                
                
                
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
                                ([guess characterAtIndex:j] == [@"\"" characterAtIndex:0] && [answer characterAtIndex:j] == [@"”" characterAtIndex:0])
                                ) {
                                
                                matchedCharsLength++;
                            }
                            
                           
                           
                        }
                        
                        
                    }

                    
                    
                    if (guessLength == matchedCharsLength) {
                        if(matchedCharsLength == answerLength && answerLength == guessLength) {
                            //if we're here, this is actually a match
                            coverGuessed = YES;
                            NSLog(@"%@", self.selectedCover.artists[i]);
                            
                        } else {
                            //if we're here, we have a partial match
                            partiallyGuessed = YES;
                        }
                        
                    }
                }
            }
        }

        
        
    }
    
    //feedback
    if (coverGuessed) {
        
        //set score & increment
        int curScore = [self.score intValue];
        int scoreIncrement = -1;
        
        //update score by score increment
        if ([campaignType isEqualToString:@"artists"]) {
            scoreIncrement = [self.selectedCover.artistLevelsScore intValue];
            [self.dba setStat:@"artistLevels" toValue:curScore+scoreIncrement];
            
        } else if ([campaignType isEqualToString:@"albums"]) {
            scoreIncrement = [self.selectedCover.albumLevelsScore intValue];
            [self.dba setStat:@"albumLevels" toValue:curScore+scoreIncrement];
            
        }
        
        self.score = [NSNumber numberWithInt:curScore + scoreIncrement];
        NSLog(@"%i", [self.score intValue]);
        
        //finish setting up guessCorrectIndicator
        [self.guessCorrectIndicator setImage:[UIImage imageNamed:@"correctIndicator.png"]];
        [self.guessCorrectIndicator setHidden:NO];
        
        //update last guessed data
        [self.dba updateLevelGuessedAtAlbumID:[albumID intValue] inMode:campaignType toValue:1];
        
        
        //update hintgained achievement state
        NSString *statusLabelText = @"Nothing";
        int totalGuessed = [self.dba getTotalLevelsGuessedForMode:campaignType];
        if ([self.dba requirementsMetFor:@"hintGained" withValue:totalGuessed] == YES) {
         
            //update hintGained achievement state
            int achievementState = [self.dba getAchievementStateFor:@"hintGained"];
            [self.dba setAchievement:@"hintGained" toState:achievementState+1];
            
            //update earnedHints
            int earnedHints = [self.dba getStat:@"earnedHints"];
            earnedHints = earnedHints + 5;
            [self.dba setStat:@"earnedHints" toValue:earnedHints];
            
            
            //update total hints value
            int originalHints = [self.dba getStat:@"originalHints"];
            int purchasedHints = [self.dba getStat:@"purchasedHints"];
            [self.dba setStat:@"totalHints" toValue:originalHints+earnedHints+purchasedHints];
            
            //Update status label message
            statusLabelText = @"You've gained 5 hints";
            
            //update total hints label
            [self.hintsLabel setText:[NSString stringWithFormat:@"Hints: %d", [self.dba getStat:@"totalHints"]]];
            
            NSLog(@"5 hints were gained");
        }
        

        NSString *addToStatus = [self levelAchievementGained:totalGuessed];
        
        //set statusLabelText to final value so we can check if statusLabel should appear
        if ([addToStatus isEqualToString:@"Nope"]) {
            if (![statusLabelText isEqualToString:@"Nothing"]) {
             
                [self.statusLabel setText:statusLabelText];
            }
        } else {
            if ([statusLabelText isEqualToString:@"Nothing"]) {
                statusLabelText = addToStatus;
            } else {
                statusLabelText = [statusLabelText stringByAppendingString:@"\n"];
                statusLabelText = [statusLabelText stringByAppendingString:addToStatus];

            }
            [self.statusLabel setText:statusLabelText];
        }
        
        if (![statusLabelText isEqualToString:@"Nothing"]) {
            //add UI elements
            [self.view addSubview:self.statusLabel];
            
            //wait 5 seconds then remove
            [self performSelector:@selector(removeStatusMessage) withObject:nil afterDelay:5];

        }
        
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
        
        
        [self showAnswer];
    }
    else if(partiallyGuessed) {
        
        //update maxscore data
        int newMaxScore = -1;
        if ([campaignType isEqualToString:@"artists"]) {
            newMaxScore = [self updateMaxScore:[self.selectedCover.artistLevelsScore intValue]];
            [self.selectedCover setArtistLevelsScore:[NSNumber numberWithInt:newMaxScore]];
        } else if([campaignType isEqualToString:@"albums"]) {
            newMaxScore = [self updateMaxScore:[self.selectedCover.albumLevelsScore intValue]];
            [self.selectedCover setAlbumLevelsScore:[NSNumber numberWithInt:newMaxScore]];
        }
        [self.dba updateLevelMaxScoreAtAlbumID:[albumID intValue] inMode:campaignType toValue:newMaxScore];
        
        //update last guessed data
        [self.dba updateLevelGuessedAtAlbumID:[albumID intValue] inMode:campaignType toValue:3];
        
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
    }
    else {
        
        //update maxscore data
        int newMaxScore = -1;
        if ([campaignType isEqualToString:@"artists"]) {
            newMaxScore = [self updateMaxScore:[self.selectedCover.artistLevelsScore intValue]];
            [self.selectedCover setArtistLevelsScore:[NSNumber numberWithInt:newMaxScore]];
        } else if([campaignType isEqualToString:@"albums"]) {
            newMaxScore = [self updateMaxScore:[self.selectedCover.albumLevelsScore intValue]];
            [self.selectedCover setAlbumLevelsScore:[NSNumber numberWithInt:newMaxScore]];
        }
        [self.dba updateLevelMaxScoreAtAlbumID:[albumID intValue] inMode:campaignType toValue:newMaxScore];
        
        //update last guessed data
        [self.dba updateLevelGuessedAtAlbumID:[albumID intValue] inMode:campaignType toValue:2];

        
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
            NSLog(@"played sound");
        }
    }
    
}

-(void)showAnswer {
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    //display full album cover
    if (IS_IPHONE5) {
      self.coverDisplay.image = [self.selectedCover answerCover];
    } else {
        [self.viewLargeCover removeFromSuperview];
        
        self.coverDisplay.frame = CGRectMake(.5*self.view.frame.size.width - 60, 80, 120, 120);
        self.coverDisplay.image = [self.selectedCover answerCover];
        
        //[self.coverDisplayLarge setHidden:NO];
        [self.view addSubview:self.coverDisplay];
    }
    
    //disable submit and use hint buttons
    [self.submitButton setEnabled:NO];
    [self.noClueButton setEnabled:NO];
    
    //disable guesses
    [self.textField setEnabled:NO];
    
    //TODO: update database
    
    
    //update score label
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %i", [self.score intValue]];
}


/*Don't get rid of
 */
- (IBAction)getRidOfLater:(id)sender {
    if ([campaignType isEqualToString:@"artists"]) {
        
        
        if([self.dba getStat:@"totalHints"] == 0) {
            
            //TODO: do something if all hints are used
            
        }
        else if([self.dba getStat:@"totalHints"] > 0) {
            NSString *hint = [self.dba useArtistHintFor:[self.selectedCover artistHint] withAlbumID:[albumID intValue]];
            [self.selectedCover setArtistHint:hint];
            self.hintLabel.text = hint;
            
            [self.dba updateArtistHintAtAlbumID:[albumID intValue] toHint:hint];
            
            [self updateHints];
        }

    }
    else if([campaignType isEqualToString:@"albums"]) {
        
        
        if([self.dba getStat:@"totalHints"] == 0) {
            //TODO: do something if all hints are used
            
        }
        else if([self.dba getStat:@"totalHints"] > 0) {
            NSString *hint = [self.dba useAlbumHintFor:[self.selectedCover albumHint] withAlbumID:[albumID intValue]];
            [self.selectedCover setAlbumHint:hint];
            self.hintLabel.text = hint;
            
            [self.dba updateAlbumHintAtAlbumID:[albumID intValue] toHint:hint];
            
            [self updateHints];
        }
        

    }

}

- (NSString *)levelAchievementGained:(int)guessedTotal {
    NSString *achiementMessage = @"Nope";
    
    //int curLocked = 1;
    
    if ([campaignType isEqualToString:@"artists"]) {
        //check corresponding unlocking achievement
        
        if ([self.dba getAchievementStateFor:@"artistsLevel1Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel1Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel1Done" toState:1];
            
            achiementMessage = @"Artists Level 2 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel2Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel2Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel2Done" toState:1];
            
            achiementMessage = @"Artists Level 3 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel3Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel3Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel3Done" toState:1];
            
            achiementMessage = @"Artists Level 4 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel4Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel4Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel4Done" toState:1];
            
            achiementMessage = @"Artists Level 5 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel5Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel5Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel5Done" toState:1];
            
            achiementMessage = @"Artists Level 6 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel6Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel6Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel6Done" toState:1];
            
            achiementMessage = @"Artists Level 7 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel7Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel7Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel7Done" toState:1];
            
            achiementMessage = @"Artists Level 8 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"artistsLevel8Done"] == 0 && [self.dba requirementsMetFor:@"artistsLevel8Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"artistsLevel8Done" toState:1];
            
            achiementMessage = @"Album Levels Campaign Unlocked";
        }
        
    }
    else if ([campaignType isEqualToString:@"albums"]) {
        //check corresponding unlocking achievement
        
        
        if ([self.dba getAchievementStateFor:@"albumsLevel1Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel1Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel1Done" toState:1];
            
            achiementMessage = @"Albums Level 2 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel2Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel2Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel2Done" toState:1];
            
            achiementMessage = @"Albums Level 3 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel3Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel3Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel3Done" toState:1];
            
            achiementMessage = @"Albums Level 4 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel4Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel4Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel4Done" toState:1];
            
            achiementMessage = @"Albums Level 5 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel5Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel5Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel5Done" toState:1];
            
            achiementMessage = @"Albums Level 6 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel6Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel6Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel6Done" toState:1];
            
            achiementMessage = @"Albums Level 7 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel7Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel7Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel7Done" toState:1];
            
            achiementMessage = @"Albums Level 8 Unlocked";
        }
        else if ([self.dba getAchievementStateFor:@"albumsLevel8Done"] == 0 && [self.dba requirementsMetFor:@"albumsLevel8Done" withValue:guessedTotal]) {
            [self.dba setAchievement:@"albumsLevel8Done" toState:1];
            
            achiementMessage = @"Strikes Mode Unlocked";
        }
    }

    
    
    return achiementMessage;
}


- (void)updateHints {
    
    int purchasedHints = [self.dba getStat:@"purchasedHints"];
    int earnedHints = [self.dba getStat:@"earnedHints"];
    int originalHints = [self.dba getStat:@"originalHints"];
    int done= 0;
    
    if(purchasedHints >0) {
        
        //update purchasedHints
        purchasedHints = purchasedHints -1;
        [self.dba setStat:@"purchasedHints" toValue:purchasedHints];
        
        done = 1;
    }
    else if(earnedHints >0 && done == 0) {
        
        //update earned hints
        earnedHints = earnedHints -1;
        [self.dba setStat:@"earnedHints" toValue:earnedHints];
        
        done = 1;
    }
    else if (originalHints >0 && done == 0) {
        
        //udate original hints
        originalHints = originalHints -1;
        [self.dba setStat:@"originalHints" toValue:originalHints];
        
        done = 1;
    }
    
    //update total hints and label
    [self.dba setStat:@"totalHints" toValue:originalHints+earnedHints+purchasedHints];
    [self.hintsLabel setText:[NSString stringWithFormat:@"Hints: %d", [self.dba getStat:@"totalHints"]]];

}

/*method to return new decremented max score value */
- (int)updateMaxScore:(int)curMaxScore {
    
    int maxScore = -1;
    
    /*u*/
    if (curMaxScore == 0) {
        maxScore =0;
    } else if (curMaxScore == 9) {
        maxScore = 0;
    } else if(curMaxScore == 22) {
        maxScore = 9;
    } else if(curMaxScore == 34) {
        maxScore = 22;
    } else if(curMaxScore == 45) {
        maxScore = 34;
    } else if(curMaxScore == 55) {
        maxScore = 45;
    } else if(curMaxScore == 64) {
        maxScore = 55;
    } else if(curMaxScore == 72) {
        maxScore = 64;
    } else if(curMaxScore == 79) {
        maxScore = 72;
    } else if(curMaxScore == 85) {
        maxScore = 79;
    } else if(curMaxScore == 90) {
        maxScore = 85;
    } else if(curMaxScore == 94) {
        maxScore = 90;
    } else if(curMaxScore == 97) {
        maxScore = 94;
    } else if(curMaxScore == 99) {
        maxScore = 97;
    } else if(curMaxScore == 100) {
        maxScore = 99;
    }
    
    
    return maxScore;
    
}


- (void)removeStatusMessage {
    [self.statusLabel removeFromSuperview];
    
    [self.statusLabel setText:@""];
}


- (IBAction)showHint:(id)sender {
    int changed =0;
    
    if ([self.hintView isHidden]) {
        [self.coverDisplay setHidden:YES];
        [self.hintView setHidden:NO];
        changed++;
        
    }
    if(changed ==0) {
        [self.hintView setHidden:YES];
        [self.coverDisplay setHidden:NO];
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

#pragma mark - UITextFieldDelegate methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)back:(id)sender {
    [self performSegueWithIdentifier:@"back" sender:self];
}




@end
