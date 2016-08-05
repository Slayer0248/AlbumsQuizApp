//
//  HighscoresViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import "UIDevice-Hardware.h"
#import "HighscoresViewController.h"
#import "HighscoreDetailViewController.h"
#import "HighscoreRowCell.h"
#import "HighscoresHeaderView.h"
#import "DBAccess.h"

@interface HighscoresViewController () <UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) DBAccess *dba;
@property (nonatomic, strong) NSMutableArray *scoreList;

@property (nonatomic, strong) NSNumber *cellNum;


@end

@implementation HighscoresViewController

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
    
    self.dba = [[DBAccess alloc] init];
    
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
        [self.collectionView setFrame:CGRectMake(0, 68+20, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
    
    
    } else {
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
    return 10;
}

// returns the total number of sections (all cells)
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


// responsible for returning the cell at a given index path. For now, this just returns an empty UICollectionViewCell.
-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    HighscoreRowCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"HighscoreRow" forIndexPath:indexPath];
    self.scoreList =[self.dba getHighscores];
    //NSLog(@"%d.....%d", indexPath.item, indexPath.row);
    
    
    [cell.rankLabel setText:[NSString stringWithFormat:@"%d.", indexPath.row+1]];
    if ([self.scoreList count] > (indexPath.item*3)) {
        
        NSLog(@"%@", [self.scoreList objectAtIndex:3*indexPath.row]);
        NSLog(@"%@", [self.scoreList objectAtIndex:(3*indexPath.row)+1]);
        
        [cell.nameLabel setText:[self.scoreList objectAtIndex:3*indexPath.row]];
        [cell.scoreLabel setText:[self.scoreList objectAtIndex:(3*indexPath.row)+1]];
    } else {
        [cell.nameLabel setText:@"---"];
        [cell.scoreLabel setText:@"---"];
    }
    
    //set text color of cell's UILabel
    [cell.rankLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [cell.nameLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    [cell.scoreLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    
    return cell;
    
    // Comment out if using a custom class.
    /*UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
     
     return cell;*/
}

// responsible for returning a view for either the header or footer for each section of the UICollectionView.
// "kind” is an NSString that determines which view (header or footer) the class is asking for.
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reuseableView = nil;
    
    if(kind == UICollectionElementKindSectionHeader) {
        HighscoresHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HighscoreHeader" forIndexPath:indexPath];
        reuseableView = header;
    } else if(kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerview = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        
        reuseableView = footerview;
    }
    
    return reuseableView;
}

// responsible for telling the layout the size of a given cell
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeMake(self.view.window.frame.size.width, 35);
    return cellSize;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellNum = [NSNumber numberWithInt:(int)indexPath.item];
    if ([self.scoreList count] > (indexPath.item*3)) {
        [self performSegueWithIdentifier:@"detailScore" sender:self];
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"detailScore"]) {
        HighscoreDetailViewController *vc = [segue destinationViewController];
        vc.rank = [NSNumber numberWithInt:[self.cellNum intValue]+1];
        vc.name = [self.scoreList objectAtIndex:[self.cellNum intValue]*3];
        vc.score = [self.scoreList objectAtIndex:([self.cellNum intValue]*3)+1];
        vc.mode = [self.scoreList objectAtIndex:([self.cellNum intValue]*3)+2];
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


// returns the spacing between the cells, headers, and footers.
/*-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
 {
 return UIEdgeInsetsMake(0, 0, 20, 0);
 }*/

@end
