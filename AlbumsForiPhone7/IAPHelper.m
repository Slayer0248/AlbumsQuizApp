//
//  IAPHelper.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/26/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "DBAccess.h"

/*NOTE: A lot of people recommend that you pull the list 
        of product identifiers from a web server along with 
        other information so you can add new in-app purchases 
        dynamically rather than requiring an app update.
 
 so probably should port this table to MySQL*/

//to receive a list of products from StoreKit
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPHelper
    // instance variable to store the SKProductsRequest
    // you will issue to retrieve a list of products,
    // while it is active. You keep a reference to the
    // request so a) you can know if you have one active already,
    // and b) you’ll be guaranteed that it’s in memory while it’s active.
    SKProductsRequest * _productsRequest;
    
    // keep track of the completion handler for the
    // outstanding products request, the list of product
    // identifiers passed in, and the list of product
    // identifiers that have been previously purchased
    RequestProductsCompletionHandler _completionHandler;
    NSSet *  _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    
    NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

    DBAccess *dba;

/* check to see which products have been purchased or not
 * (based on the values saved in NSUserDefaults) and keep 
 * track of the product identifiers that have been purchased
 * in a list*/
-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    
    if ((self = [super init])) {
        
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        // [NSMutableSet set] creates new empty set
        _purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            } else {
                NSLog(@"Not purchased: %@", productIdentifier);
            }
        }
        dba = [[DBAccess alloc] init];
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    
    return self;
}


- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    
    // copies completion handler block inside the instance variable
    // so it can notify the caller when the product request
    // asynchronously completes.
    _completionHandler = [completionHandler copy];
    
    // creates a new instance of SKProductsRequest,
    // which is the Apple-written class that contains
    // the code to pull the info from iTunes Connect.
    // Just give it a delegate (that conforms to the
    //SKProductsRequestDelegate protocol) and then call start
    NSLog(@"In completion handler");
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
    
}


#pragma mark - SKProductsRequestDelegate

/* IAPHelper class is delegate, and these are the callback method*/

/*Success callback*/
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Loaded list of products...");
    _productsRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
    
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

/*Fail callback*/
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product {
    NSLog(@"Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"In here");
    
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //[self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                //[self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //TODO: Add coresponding number of hints to overall stats table
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"restore transaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    //TODO: Add coresponding number of hints to overall stats table
}

// happens if user starts a purchase (and gets charged for it),
// but before Apple can respond with success or failure, the
// user suddenly loses network connection (or terminates your app)
- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"failed transaction...");
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    //very important to call finishTransaction, or StoreKit will
    //not know you’ve finished processing it, and will continue
    //delivering the transaction to your app each time it launches!
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier {
    
    int curPurchasedHints = [dba getStat:@"purchasedHints"];
    int curTotalHints = [dba getStat:@"totalHints"];
    int hintIncrement =-1;
    
    
    if ([productIdentifier isEqualToString:@"com.CJDev.AlbumsForiPhone7.5Hints"]) {
        
        //consumable, 5 more hints
        hintIncrement = 5;
        [dba setStat:@"purchasedHints" toValue:curPurchasedHints + hintIncrement];
        [dba setStat:@"totalHints" toValue:curTotalHints + hintIncrement];
        
    } else if ([productIdentifier isEqualToString:@"com.CJDev.AlbumsForiPhone7.10Hints"]) {
        
        //consumable, 10 more hints
        hintIncrement = 10;
        [dba setStat:@"purchasedHints" toValue:curPurchasedHints + hintIncrement];
        [dba setStat:@"totalHints" toValue:curTotalHints + hintIncrement];
        
    } else if ([productIdentifier isEqualToString:@"com.CJDev.AlbumsForiPhone7.25Hints"]) {
        
        //consumable, 25 more hints
        hintIncrement = 25;
        [dba setStat:@"purchasedHints" toValue:curPurchasedHints + hintIncrement];
        [dba setStat:@"totalHints" toValue:curTotalHints + hintIncrement];
        
    } else if ([productIdentifier isEqualToString:@"com.CJDev.AlbumsForiPhone7.100Hints"]) {
        
        //consumable, 100 more hints
        hintIncrement = 100;
        [dba setStat:@"purchasedHints" toValue:curPurchasedHints + hintIncrement];
        [dba setStat:@"totalHints" toValue:curTotalHints + hintIncrement];
        
    } else {
        //non-consumable
        [_purchasedProductIdentifiers addObject:productIdentifier];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }

    curTotalHints = [dba getStat:@"totalHints"];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
    
    if (hintIncrement != -1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Purchase Successful"message:[NSString stringWithFormat:@"You just bought %d hints and now have %d hints total.", hintIncrement, curTotalHints] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void)restoreCompletedTransactions {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
