//
//  IAPHelper.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/26/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

//initializer that takes a list of product identifiers
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

//a method to retrieve information about the products from iTunes Connect
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

//a method to start buying a product
- (void)buyProduct:(SKProduct *)product;

//a method to determine if a product has been purchased
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

@end
