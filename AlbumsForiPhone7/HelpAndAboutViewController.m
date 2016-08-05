//
//  HelpAndAboutViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 4/2/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "HelpAndAboutViewController.h"
#import "UIDevice-Hardware.h"

@interface HelpAndAboutViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

    @property (nonatomic, weak) IBOutlet UIButton *backButton;
    @property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
    @property (nonatomic, strong) UIButton *helpButton;
    @property (nonatomic, strong) UIButton *aboutButton;
    @property (nonatomic, strong) UIImageView *logo;
@end

@implementation HelpAndAboutViewController

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
    
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    [self.collectionView setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    //set positions of UI Elements
    if (IS_IPHONE5) {
        [self.collectionView setFrame:CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
             [modelOther isEqualToString:@"iPad 3"] ||
             [modelOther isEqualToString:@"iPad 4"] ||
             [modelOther isEqualToString:@"iPad Air"] ||
             [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.collectionView setFrame:CGRectMake(0, 68+20, self.view.frame.size.width, self.view.frame.size.height - 88)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
    }
    else {
        [self.collectionView setFrame:CGRectMake(0, 60, self.view.frame.size.width, 392)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    
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
    return 3;
}

// returns the total number of sections (all cells)
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


// responsible for returning the cell at a given index path. For now, this just returns an empty UICollectionViewCell.
-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"LinkCell" forIndexPath:indexPath];
   
    cell.backgroundColor = [self colorWithHexString:@"0058bb"];
    //NSLog(@"%d.....%d", indexPath.item, indexPath.row);
    
    if (indexPath.item == 0) {
        
        self.helpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //set up button title
        NSDictionary *attrDict = @{NSFontAttributeName : [UIFont systemFontOfSize:27.0],NSForegroundColorAttributeName : [UIColor whiteColor]};
        NSString *commentString= @"Get Help";
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"Get Help" attributes: attrDict];
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
        [self.helpButton setAttributedTitle:title forState:UIControlStateNormal];
        [self.helpButton setFrame:CGRectMake(.5*self.view.frame.size.width -73, 0, 146, 73)];
        [self.helpButton addTarget:self action:@selector(helpPage) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.helpButton];
    }
    else if (indexPath.item == 1) {
        
        self.aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        //set up button title
        NSDictionary *attrDict = @{NSFontAttributeName : [UIFont systemFontOfSize:27.0],NSForegroundColorAttributeName : [UIColor whiteColor]};
        NSString *commentString= @"About Me";
        NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"About Me" attributes: attrDict];
        [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
        [self.aboutButton setAttributedTitle:title forState:UIControlStateNormal];
        [self.aboutButton setFrame:CGRectMake(.5*self.view.frame.size.width -73, 0, 146, 73)];
        [self.aboutButton addTarget:self action:@selector(helpPage) forControlEvents:UIControlEventTouchUpInside];
        
        [cell addSubview:self.aboutButton];
    }
    else if (indexPath.item == 2) {
        self.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CJDevLogoApp.png"]];
        [self.logo setFrame:CGRectMake(.5*self.view.frame.size.width -73, 0, 146, 73)];
        [cell addSubview:self.logo];
    }
    
    return cell;
    
    // Comment out if using a custom class.
    /*UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
     
     return cell;*/
}

// responsible for returning a view for either the header or footer for each section of the UICollectionView.
// "kind” is an NSString that determines which view (header or footer) the class is asking for.
/*-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reuseableView = nil;
    
    if(kind == UICollectionElementKindSectionHeader) {
        HighscoresHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HighscoreHeader" forIndexPath:indexPath];
        reuseableView = header;
    } else if(kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reuseableView = footerview;
    }
    
    return reuseableView;
}*/

// responsible for telling the layout the size of a given cell
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize;
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    if([model isEqualToString:@"iPadSimulator"] ||
       [modelOther isEqualToString:@"iPad 3"] ||
       [modelOther isEqualToString:@"iPad 4"] ||
       [modelOther isEqualToString:@"iPad Air"] ||
       [modelOther isEqualToString:@"iPad Mini Retina"]) {
        cellSize = CGSizeMake(self.view.window.frame.size.width, 73);
    }
    else {
        cellSize = CGSizeMake(self.view.window.frame.size.width, 73);
    }
    
    return cellSize;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    if([model isEqualToString:@"iPadSimulator"] ||
       [modelOther isEqualToString:@"iPad 3"] ||
       [modelOther isEqualToString:@"iPad 4"] ||
       [modelOther isEqualToString:@"iPad Air"] ||
       [modelOther isEqualToString:@"iPad Mini Retina"]) {
        return UIEdgeInsetsMake(40, 0, 40, 0);
    }
    else {
        return UIEdgeInsetsMake(100, 0, 100, 0);
    }
}

#pragma mark - UIButton selectors
-(void)helpPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cjdevproductions.com"]];
}

-(void)aboutPage {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cjdevproductions.com"]];
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
