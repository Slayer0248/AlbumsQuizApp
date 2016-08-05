//
//  StoreViewController.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/26/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "UIDevice-Hardware.h"
#import "StoreViewController.h"
#import "AlbumsIAPHelper.h"
#import "ViewController.h"
#import "DBAccess.h"
#import <StoreKit/StoreKit.h>

@interface StoreViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

    @property (nonatomic, strong) IBOutlet UIButton *backButton;
    @property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
    @property (nonatomic, strong) UILabel *statusLabel;

    @property (nonatomic, strong) UIRefreshControl *refreshControl;
    
    @property (nonatomic, strong) NSArray *_products;

    @property (nonatomic, strong) DBAccess *dba;
    @property (nonatomic, strong) NSMutableArray *storeProducts;
    @property (nonatomic, strong) NSMutableArray *levelButtonCells;
@end

@implementation StoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
    
}

/**/
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //change background color
    [self.view setBackgroundColor:[self colorWithHexString:@"0058bb"]];
    
    //[self.collectionView setHidden:YES];
    //TODO: Implement collection view
    //set up collectionVeiw
    [self.collectionView setDataSource:self];
    [self.collectionView setDelegate:self];
    
    [self.collectionView setBackgroundColor:[self colorWithHexString:@"0058bb"]];

    //set up refresh control
    //self.refreshControl = [[UIRefreshControl alloc] init];
    //[self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    //[self.collectionView addSubview:self.refreshControl];
    //[self.collectionView addSubview:self.refreshControl];
    //self.collectionView.alwaysBounceHorizontal = YES;
    
    //[self reload];
    //[self.refreshControl beginRefreshing];
    
    //setup status label
    self.statusLabel = [[UILabel alloc] init];
    [self.statusLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [self.statusLabel setNumberOfLines:0];
    [self.statusLabel setTextAlignment:NSTextAlignmentCenter];
    [self.statusLabel setBackgroundColor:[self colorWithHexString:@"00234b"]];
    [self.statusLabel setTextColor:[self colorWithHexString:@"ffffff"]];
    //[self.statusLabel setText:@"Loading products"];
    //[self.view addSubview:self.statusLabel];
    
    //get device type
    UIDevice_Hardware *test = [[UIDevice_Hardware alloc] init];
    
    NSString *model = [[UIDevice currentDevice] model];
    NSString *modelOther = [test hardwareSimpleDescription];

    
    
    if (IS_IPHONE5) {
        [self.collectionView setFrame:CGRectMake(0, 68, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
        [self.statusLabel setFrame:CGRectMake(5, 68, self.view.frame.size.width-10, self.view.frame.size.height - 68)];
    }
    else if([model isEqualToString:@"iPadSimulator"] ||
            [modelOther isEqualToString:@"iPad 3"] ||
            [modelOther isEqualToString:@"iPad 4"] ||
            [modelOther isEqualToString:@"iPad Air"] ||
            [modelOther isEqualToString:@"iPad Mini Retina"]) {
        [self.collectionView setFrame:CGRectMake(0, 68+20, self.view.frame.size.width, self.view.frame.size.height - 68)];
        [self.backButton setFrame:CGRectMake(14, 15+20, 72, 44)];
        [self.statusLabel setFrame:CGRectMake(5, 68+20, self.view.frame.size.width-10, self.view.frame.size.height - 68)];
        
    } else {
        [self.collectionView setFrame:CGRectMake(0, 60, self.view.frame.size.width, 392)];
        [self.backButton setFrame:CGRectMake(14, 15, 72, 44)];
        [self.statusLabel setFrame:CGRectMake(5, 60, self.view.frame.size.width-10, 392)];
    }

    self.dba = [[DBAccess alloc] init];
    self.storeProducts = [self.dba getIProductIDs];
    //TODO: Implement restore purchases button
    
    
    [self.collectionView reloadData];
    [[AlbumsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            self._products = products;
            [self.collectionView reloadData];
        }
        else {
            [self.collectionView removeFromSuperview];
            
            [self.statusLabel setText:@"Failed to load products. Please try again later."];
            [self.view addSubview:self.statusLabel];
        }
    }];
    
    //NSLog(@"%d", [self._products count]);
    
    //self._products=[NSArray arrayWithArray:[self sortNumericPrefixArray:self._products toLength:[self._products count]]];
    
}

/*-(void)reload {
    self._products = nil;
    [self.collectionView reloadData];
    [[AlbumsIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
         NSLog(@"Waiting");
        if (success) {
            self._products = products;
            [self.collectionView reloadData];
            //[self.collectionView setHidden:NO];
            [self.statusLabel setHidden:YES];
        }
        else {
            [self.collectionView removeFromSuperview];
   
            [self.statusLabel setText:@"Failed to load products. Please try again later."];
            [self.view addSubview:self.statusLabel];
        }
        [self.refreshControl endRefreshing];
    }];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}*/

/*- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [self._products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            //[self.collectionView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}*/



#pragma mark - UICollectionView methods

//TODO: Implement collection view methods
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *productID =[self.storeProducts objectAtIndex:indexPath.item];
    
    SKProduct *product;
    
    if (indexPath.item == 0) {
        product = self._products[3];
        
    } else if (indexPath.item >=1 && indexPath.item <=2) {
        product = self._products[indexPath.item];
        
    } else  if (indexPath.item == 3) {
        product = self._products[0];
    }
        
        
    //SKProduct *product = (SKProduct *)self._products[indexPath.item];
    
    

    
    NSLog(@"%@ vs %@", productID, product.productIdentifier);
    
    //SKProduct *product = (SKProduct *)self._products[indexPath.item];
    
    if (product.productIdentifier == NULL) {
        NSLog(@"Can't buy %@...", product.productIdentifier);
    } else {
        NSLog(@"Buying %@...", product.productIdentifier);
        [[AlbumsIAPHelper sharedInstance] buyProduct:product];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

//returns the number of cells to be displayed for a given section
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return [self.storeProducts count];
}


//returns the total number of sections
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSMutableArray *)sortNumericPrefixArray:(NSArray*)array toLength:(int)n {
    /*for (int i=0; i<[array count]; i++) {
        NSString *first = [array objectAtIndex:i];
        for (int j=0; j<[first length]; j++) {
            while ([first characterAtIndex:j] >= '0' && [first characterAtIndex:j] >= '9'){
            
            }
        }
    }*/

    NSMutableArray *result = [NSMutableArray arrayWithArray:array];
    //Insertion sort
    
    for(int k=2; k<= n; k++) {
        NSString *temp = [result objectAtIndex:k-1];
        int i;
        for (i=k-1; i>0; i++) {
            if([[result objectAtIndex:i-1] compare:temp options:NSNumericSearch] == NSOrderedAscending || [[result objectAtIndex:i-1] compare:temp options:NSNumericSearch] == NSOrderedSame) {
                break;
            }
            else {
                [result replaceObjectAtIndex:i withObject:[result objectAtIndex:i-1]];
            }
        }
        [result replaceObjectAtIndex:i withObject:temp];
    }
    
    return result;
    //NSString *first = [array objectAtIndex:<#(NSUInteger)#>]
}

//returning the cell at a given index path.
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProductCell" forIndexPath:indexPath];
    
    SKProduct *product;
    
    if (indexPath.item == 0) {
        product = (SKProduct *)self._products[3];
        
    } else if (indexPath.item >=1 && indexPath.item <=2) {
        product = (SKProduct *)self._products[indexPath.item];
        
    } else  if (indexPath.item == 3) {
        product = (SKProduct *)self._products[0];
    }
    
    //product.
    int category = [self.dba getCategoryIDWithiTunesProductID:[self.storeProducts objectAtIndex:indexPath.item]];
    
    //NSString
    [cell removeFromSuperview];
    [cell.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSLog(@"Product Identifier: %@", product.productIdentifier);
    //if (!(product.productIdentifier == NULL)) {
    
    
        if (category == 0) {
        
            UIImageView *cellImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HintProductButton.png"]];
            [cellImage setFrame:CGRectMake(5, 11, self.view.window.frame.size.width-30, 250)];
            [cell addSubview:cellImage];

            //[self.storeProducts objectAtIndex:indexPath.item]
        
            NSString *productName = [self.dba getProductNameWithiTunesProductID:[self.storeProducts objectAtIndex:indexPath.item]];
            NSString *price = [self.dba getProductPriceWithiTunesProductID:[self.storeProducts objectAtIndex:indexPath.item]];
            
            NSString *productString;
            if (product.productIdentifier == NULL) {
                productString = @"Loading";
            } else {
                productString = [productName stringByAppendingString:@"\n\n"];
                productString = [productString stringByAppendingString:price];
            }
            //NSLog(@"%@", productName);
        
            UILabel *productLabel = [[UILabel alloc] init];
            [productLabel setText:productString];
            [productLabel setTextAlignment:NSTextAlignmentCenter];
            [productLabel setNumberOfLines:0];
            [productLabel setTextColor:[self colorWithHexString:@"ffffff"]];
            [productLabel setFont:[UIFont fontWithName:@"Helvetica" size:20.0f]];
            [productLabel setFrame:CGRectMake(.5*self.view.window.frame.size.width-70, 150, 120, 80)];
            [cell addSubview:productLabel];

        
        
        }
    
    //}
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

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (self.collectionView.tracking) {
        CGFloat diff = contentInset.top - self.collectionView.contentInset.top;
        CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView];
        translation.y -= diff * 3.0 / 2.0;
        [self.collectionView.panGestureRecognizer setTranslation:translation inView:self.collectionView];
    }
    [self.collectionView setContentInset:contentInset];
}
 
 

#pragma mark - IBActions

-(IBAction)back:(id)sender {
    
}

- (void)restoreTapped:(id)sender {
    [[AlbumsIAPHelper sharedInstance] restoreCompletedTransactions];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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
