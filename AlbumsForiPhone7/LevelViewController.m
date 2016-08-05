//
//  LevelViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 1/13/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "LevelViewController.h"
#import "DBAccess.h"
#import "LevelSelectViewController.h"
#import "AlbumCover.h"
#import "GuessViewController.h"
#import "AlbumCell.h"
#import "UIDevice-Hardware.h"

@interface LevelViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


    @property (nonatomic, strong) IBOutlet UICollectionView *albumSelection;
    @property (nonatomic, strong) IBOutlet UIButton *backButton;

    @property (nonatomic, strong
               ) NSMutableArray *levelCovers;
    @property (nonatomic, strong) NSMutableArray *chosenCovers;

    @property (nonatomic, strong) NSNumber *albumID;

    @property (nonatomic, strong) DBAccess *dba;

    @property (nonatomic, retain) AlbumCover *cover;
@end

@implementation LevelViewController

@synthesize campaignType, levelSelected, score;

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
    
    //NSLog(@"%ld", (long)levelSelected);
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    [self.albumSelection setDataSource:self];
    [self.albumSelection setDelegate:self];
    
    [self.albumSelection setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //[self.albumSelection registerClass:[AlbumCell class] forCellWithReuseIdentifier:@"AlbumCell"];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];
    
    
    if (IS_IPHONE5) {
        [self.albumSelection setFrame:CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.albumSelection setFrame:CGRectMake(0, 60+20, self.view.frame.size.width, 372)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
    
    } else {
        [self.albumSelection setFrame:CGRectMake(0, 60, self.view.frame.size.width, 392)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
    }
    
    self.dba = [[DBAccess alloc] init];
    self.levelCovers = [[NSMutableArray alloc] init];
    
    //self.allCovers = [self.dba getAlbums];
    
    
    /*Performance Optimization*/
    /*Pros = quick transitions to new views throughout app Cons = requires  */
    
    dispatch_queue_t my_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(my_queue_t, ^{
        
        //new thread so no UI code
        int d= [levelSelected intValue]-1;
        
        //set up collection view albums array
        if ([levelSelected intValue] < 7) {
            int curCover = d*31;
            while (curCover < (d+1)*31) {
                [self.levelCovers addObject:[self.dba getDetailCoverFileAtAlbumID:curCover]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.albumSelection reloadData];
                });
                curCover++;
                
            }
            
            //self.levelCovers = [self.dba getAlbumCoversAtAlbumID:d*31 withLimit:(d+1)*31];
            
        } else {
            int curCover = 186 + ((d-6)*32);
            while (curCover < 186 +((d-5)*32)) {
                [self.levelCovers addObject:[self.dba getDetailCoverFileAtAlbumID:curCover]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.albumSelection reloadData];
                });
                curCover++;
                
            }
            
            // self.levelCovers = [self.dba getAlbumCoversAtAlbumID:186 + ((d-6)*32) withLimit:186 +((d-5)*32)];
            
        }
        
        
    });

    
    

    //NSLog(@"Success");
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int d= [levelSelected intValue]-1;
    
    if ([levelSelected intValue] < 7) {
        
        //[self.levelCovers removeAllObjects];
        //NSLog(@"%d", ((d*31)+indexPath.item)%31);
        if (IS_IPHONE5) {
            self.albumID = [[NSNumber alloc] initWithInt:(d*31) +(int)indexPath.item + ((int)(indexPath.section)*15)];
        }
        else {
            self.albumID = [[NSNumber alloc] initWithInt:(d*31) +(int)indexPath.item + ((int)(indexPath.section)*12)];
        }
    }
    else {
       // NSLog(@"%d", (((d-6)*32) +indexPath.item)%32);
        self.albumID = [[NSNumber alloc] initWithInt:186 + ((d-6)*32) +(int)indexPath.item + ((int)(indexPath.section)*15)];
        //[self.levelCovers removeAllObjects];
        
        if (IS_IPHONE5) {
            self.albumID = [[NSNumber alloc] initWithInt:186 + ((d-6)*32) +(int)indexPath.item + ((int)(indexPath.section)*15)];
        }
        else {
            self.albumID = [[NSNumber alloc] initWithInt:186 + ((d-6)*32) +(int)indexPath.item + ((int)(indexPath.section)*12)];
        }
    }
    
    AlbumCover *cover;
    
    if (IS_IPHONE5) {
        cover = [self.levelCovers objectAtIndex:indexPath.item + ((indexPath.section)*15)];
    } else {
        cover = [self.levelCovers objectAtIndex:indexPath.item + ((indexPath.section)*12)];
    }
    
    int wasGuessed = -1;
    
    if ([campaignType isEqualToString:@"artists"]) {
        wasGuessed = [cover.artistLevelsGuessed intValue];
    } else if([campaignType isEqualToString:@"albums"]) {
        wasGuessed = [cover.albumLevelsGuessed intValue];
    }
    
    if (wasGuessed==1) {
        
    }else {
        [self performSegueWithIdentifier:@"toGuessScreen" sender:self];
    }
        
        
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}



#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"toGuessScreen"]) {
        
        GuessViewController *guessScreen = [segue destinationViewController];
        guessScreen.levelSelected = self.levelSelected;
        guessScreen.campaignType = self.campaignType;
        guessScreen.albumID = self.albumID;
        guessScreen.score = self.score;
        
        //CFRelease(self.levelCovers);
        
    }
    else if([segue.identifier isEqualToString:@"backLevelSelect"]) {
        LevelSelectViewController *lSelect = [segue destinationViewController];
        lSelect.campaignType = self.campaignType;
        lSelect.score = self.score;
        
    }

}


#pragma mark - UICollectionViewDelegate

//returns the number of cells to be displayed for a given section
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    /*if ([levelSelected intValue] < 7) {
        return 31;
    }
    else {
        return 32;
    }*/
    if (IS_IPHONE5) {
        if (section <2) {
            return 15;
        }
        else {
            if ([levelSelected intValue] < 7) {
                return 1;
            }
            else {
                return 2;
            }
        }

    }
    else {
        
        if (section <2) {
            return 12;
        }
        else {
            if ([levelSelected intValue] < 7) {
                return 7;
            }
            else {
                return 8;
            }
        }

    }
}
//returns the total number of sections
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 3;
}

-(NSInteger)getNumberOfAlbumsInLevel:(int)level {
    if ([levelSelected intValue] < 7) {
        return 31;
    }
    else {
        return 32;
    }
}

/*- (AlbumCell*) collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = (AlbumCell *)[cv dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    
    
    if([self.levelCovers count] > indexPath.item + ((indexPath.section)*15)) {
        AlbumCover *cover = [self.levelCovers objectAtIndex:indexPath.item + ((indexPath.section)*15)];
        
        //NSLog(@"%@", cover.answers[0]);
        UIImageView *cellImage = [[UIImageView alloc] initWithImage:cover.questionCover];
        [cellImage setFrame:cell.bounds];
        
        //WithFrame:CGRectMake(65, 65, 15, 15)
        UIImageView *guessStateImage = [[UIImageView alloc] init];
        int addImage = 1;
        
        if ([campaignType isEqualToString:@"artists"]) {
            NSLog(@"cover guessed = %d", [cover.artistLevelsGuessed intValue]);
            if([cover.artistLevelsGuessed intValue]==0){
                addImage = 0;
            }
            if([cover.artistLevelsGuessed intValue]==1){
                guessStateImage.image = [UIImage imageNamed:@"correctIndicator.png"];
                
            }
            if([cover.artistLevelsGuessed intValue]==2){
                guessStateImage.image = [UIImage imageNamed:@"wrongIndicator.png"];
            }
            if([cover.artistLevelsGuessed intValue]==3){
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectIndicator.png"];
            }
        } else if([campaignType isEqualToString:@"albums"]) {
            if([cover.albumLevelsGuessed intValue]==0){
                addImage = 0;
            }
            else if([cover.albumLevelsGuessed intValue]==1){
                //[guessStateImage setImage:[UIImage imageNamed:@"correctIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"correctIndicator.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==2){
                //[guessStateImage setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"wrongIndicator.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==3){
                //[guessStateImage setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectIndicator.png"];
            }
        }
        
        
        //[cellImage setFrame:CGRectMake(((indexPath.item % 3)+1)*18 + ((indexPath.item % 3)-1)*80, ((indexPath.item % 3)-1)*80 + ((indexPath.item % 3)-1)*10, 80, 80)];
        
    
        cell.coverView = cellImage;
        if (addImage == 1) {
            NSLog(@"image added");
            //[cell addSubview:guessStateImage];
            cell.guessStateView = guessStateImage;
        }
    }
    //[self.levelButtonCells insertObject:cell atIndex:indexPath.item];
    return cell;

}*/

//returning the cell at a given index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"AlbumCell" forIndexPath:indexPath];
    //(AlbumCell *)
    
    if(IS_IPHONE5 && [self.levelCovers count] > indexPath.item + ((indexPath.section)*15)) {
        AlbumCover *cover = [self.levelCovers objectAtIndex:indexPath.item + ((indexPath.section)*15)];
        
        //NSLog(@"%@", cover.answers[0]);
        UIImageView *cellImage = [[UIImageView alloc] initWithImage:cover.questionCover];
        [cellImage setFrame:cell.bounds];
        
        
        
        //WithFrame:CGRectMake(65, 65, 15, 15)
        UIImageView *guessStateImage = [[UIImageView alloc] init];
        int addImage = 1;
        
        if ([campaignType isEqualToString:@"artists"]) {
           // NSLog(@"cover guessed = %d", [cover.artistLevelsGuessed intValue]);
            if([cover.artistLevelsGuessed intValue]==0){
                addImage = 0;
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
                
            }
            if([cover.artistLevelsGuessed intValue]==1){
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
                
            }
            if([cover.artistLevelsGuessed intValue]==2){
                guessStateImage.image = [UIImage imageNamed:@"wrongSmall.png"];
            }
            if([cover.artistLevelsGuessed intValue]==3){
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectSmall.png"];
            }
        } else if([campaignType isEqualToString:@"albums"]) {
            if([cover.albumLevelsGuessed intValue]==0){
                addImage = 0;
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==1){
                //[guessStateImage setImage:[UIImage imageNamed:@"correctIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==2){
                //[guessStateImage setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"wrongSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==3){
                //[guessStateImage setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectSmall.png"];
            }
        }
        
        
        //[cellImage setFrame:CGRectMake(((indexPath.item % 3)+1)*18 + ((indexPath.item % 3)-1)*80, ((indexPath.item % 3)-1)*80 + ((indexPath.item % 3)-1)*10, 80, 80)];
        
        
        cell.coverView.image = cellImage.image;
        if (addImage == 1) {
            NSLog(@"image added");
            //[cell addSubview:guessStateImage];
            cell.guessStateView.image = guessStateImage.image;
            [cell.guessStateView setHidden:NO];
        } else if(addImage == 0){
            [cell.guessStateView setHidden:YES];
        }
    }
    
    
    else if(!IS_IPHONE5 && [self.levelCovers count] > indexPath.item + ((indexPath.section)*12)) {
        AlbumCover *cover = [self.levelCovers objectAtIndex:indexPath.item + ((indexPath.section)*12)];
        
        //NSLog(@"%@", cover.answers[0]);
        UIImageView *cellImage = [[UIImageView alloc] initWithImage:cover.questionCover];
        [cellImage setFrame:cell.bounds];
        
        
        
        //WithFrame:CGRectMake(65, 65, 15, 15)
        UIImageView *guessStateImage = [[UIImageView alloc] init];
        int addImage = 1;
        
        if ([campaignType isEqualToString:@"artists"]) {
            NSLog(@"cover guessed = %d", [cover.artistLevelsGuessed intValue]);
            if([cover.artistLevelsGuessed intValue]==0){
                addImage = 0;
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
                
            }
            if([cover.artistLevelsGuessed intValue]==1){
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
                
            }
            if([cover.artistLevelsGuessed intValue]==2){
                guessStateImage.image = [UIImage imageNamed:@"wrongSmall.png"];
            }
            if([cover.artistLevelsGuessed intValue]==3){
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectSmall.png"];
            }
        } else if([campaignType isEqualToString:@"albums"]) {
            if([cover.albumLevelsGuessed intValue]==0){
                addImage = 0;
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==1){
                //[guessStateImage setImage:[UIImage imageNamed:@"correctIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"correctSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==2){
                //[guessStateImage setImage:[UIImage imageNamed:@"wrongIndicator.png"]];
                guessStateImage.image = [UIImage imageNamed:@"wrongSmall.png"];
            }
            else if([cover.albumLevelsGuessed intValue]==3){
                //[guessStateImage setImage:[UIImage imageNamed:@"partiallyCorrectIndicator.png"]];
                guessStateImage.image =[UIImage imageNamed:@"partiallyCorrectSmall.png"];
            }
        }
        
        
        //[cellImage setFrame:CGRectMake(((indexPath.item % 3)+1)*18 + ((indexPath.item % 3)-1)*80, ((indexPath.item % 3)-1)*80 + ((indexPath.item % 3)-1)*10, 80, 80)];
        
        
        cell.coverView.image = cellImage.image;
        if (addImage == 1) {
            NSLog(@"image added");
            //[cell addSubview:guessStateImage];
            cell.guessStateView.image = guessStateImage.image;
            [cell.guessStateView setHidden:NO];
        } else if(addImage == 0){
            [cell.guessStateView setHidden:YES];
        }
    }

    //[self.levelButtonCells insertObject:cell atIndex:indexPath.item];
    return cell;

 }

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(80, 80);
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    double sidePadding = (self.view.frame.size.width-260)/2;
    //NSLog(@"%f", sidePadding);
    
    if(section <2) {
        return UIEdgeInsetsMake(10, sidePadding, 10, sidePadding);
    } else {
        return UIEdgeInsetsMake(10, sidePadding, 10, self.view.frame.size.width-(80+sidePadding));
    }



}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    /*Avoid memory leaks by*/
    //set images to nil
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
    [self performSegueWithIdentifier:@"backLevelSelect" sender:self];
}



@end
