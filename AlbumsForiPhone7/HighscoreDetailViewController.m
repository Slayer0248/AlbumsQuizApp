//
//  HighscoreDetailViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/29/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "UIDevice-Hardware.h"
#import "HighscoreDetailViewController.h"

@interface HighscoreDetailViewController ()
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (strong, nonatomic) IBOutlet UILabel *scoreHeader;
@property (strong, nonatomic) IBOutlet UILabel *nameHeader;
@property (strong, nonatomic) IBOutlet UILabel *modeHeader;

@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *modeLabel;


@end

@implementation HighscoreDetailViewController

@synthesize name, score, mode;
@synthesize rank;

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
    
    //change backgroud color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //change label text
    [self.rankLabel setText:[NSString stringWithFormat:@"Score #%d", [rank intValue]]];
    [self.nameLabel setText:name];
    [self.scoreLabel setText:score];
    [self.modeLabel setText:mode];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    if (IS_IPHONE5) {
        
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
        [self.rankLabel setFrame:CGRectMake(0, self.backButton.frame.origin.y + self.backButton.frame.size.height+16, self.view.frame.size.width, 33)];
        [self.scoreHeader setFrame:CGRectMake(0, self.rankLabel.frame.origin.y + self.rankLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.scoreLabel setFrame:CGRectMake(0, self.scoreHeader.frame.origin.y + self.scoreHeader.frame.size.height+8, self.view.frame.size.width, 21)];
        [self.nameHeader setFrame:CGRectMake(0, self.scoreLabel.frame.origin.y + self.scoreLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.nameLabel setFrame:CGRectMake(0, self.nameHeader.frame.origin.y + self.nameHeader.frame.size.height+8, self.view.frame.size.width, 21)];
        [self.modeHeader setFrame:CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.modeLabel setFrame:CGRectMake(0, self.modeHeader.frame.origin.y + self.modeHeader.frame.size.height+8, self.view.frame.size.width, 21)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
        [self.rankLabel setFrame:CGRectMake(0, self.backButton.frame.origin.y + self.backButton.frame.size.height+16+20, self.view.frame.size.width, 33)];
        [self.scoreHeader setFrame:CGRectMake(0, self.rankLabel.frame.origin.y + self.rankLabel.frame.size.height+8+20, self.view.frame.size.width, 24)];
        [self.scoreLabel setFrame:CGRectMake(0, self.scoreHeader.frame.origin.y + self.scoreHeader.frame.size.height+8+20, self.view.frame.size.width, 21)];
        [self.nameHeader setFrame:CGRectMake(0, self.scoreLabel.frame.origin.y + self.scoreLabel.frame.size.height+8+20, self.view.frame.size.width, 24)];
        [self.nameLabel setFrame:CGRectMake(0, self.nameHeader.frame.origin.y + self.nameHeader.frame.size.height+8+20, self.view.frame.size.width, 21)];
        [self.modeHeader setFrame:CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height+8+20, self.view.frame.size.width, 24)];
        [self.modeLabel setFrame:CGRectMake(0, self.modeHeader.frame.origin.y + self.modeHeader.frame.size.height+8+20, self.view.frame.size.width, 21)];
    
    
    
    
    } else {
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
        [self.rankLabel setFrame:CGRectMake(0, self.backButton.frame.origin.y + self.backButton.frame.size.height+16, self.view.frame.size.width, 33)];
        [self.scoreHeader setFrame:CGRectMake(0, self.rankLabel.frame.origin.y + self.rankLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.scoreLabel setFrame:CGRectMake(0, self.scoreHeader.frame.origin.y + self.scoreHeader.frame.size.height+8, self.view.frame.size.width, 21)];
        [self.nameHeader setFrame:CGRectMake(0, self.scoreLabel.frame.origin.y + self.scoreLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.nameLabel setFrame:CGRectMake(0, self.nameHeader.frame.origin.y + self.nameHeader.frame.size.height+8, self.view.frame.size.width, 21)];
        [self.modeHeader setFrame:CGRectMake(0, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height+8, self.view.frame.size.width, 24)];
        [self.modeLabel setFrame:CGRectMake(0, self.modeHeader.frame.origin.y + self.modeHeader.frame.size.height+8, self.view.frame.size.width, 21)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


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
