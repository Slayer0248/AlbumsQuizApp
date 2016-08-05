//
//  AlbumsIAPHelper.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 3/26/14.
//  Copyright (c) 2014 CJDev. All rights reserved.
//

#import "AlbumsIAPHelper.h"
#import "DBAccess.h"

@interface AlbumsIAPHelper ()



@end

@implementation AlbumsIAPHelper

+ (AlbumsIAPHelper *)sharedInstance {
    
    static dispatch_once_t once;
    static AlbumsIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        
        //Bundle ID = com.CJDev.AlbumsForiPhone7

        NSMutableSet * productIdentifiers = [NSMutableSet setWithObjects:
                                      @"com.CJDev.AlbumsForiPhone7.5Hints",
                                      @"com.CJDev.AlbumsForiPhone7.10Hints",
                                      @"com.CJDev.AlbumsForiPhone7.25Hints",
                                      @"com.CJDev.AlbumsForiPhone7.100Hints",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
