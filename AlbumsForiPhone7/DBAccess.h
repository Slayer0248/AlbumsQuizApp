//
//  DBAccess.h
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AlbumCover.h"

@interface DBAccess : NSObject

//Database methods
+ (NSString*) getDBPath;
+ (void) copyDatabaseIfNeeded;

//albumAnswers & albumCovers tables methods

//preferably not use with large db.
- (NSMutableArray *) getAlbums;

//use to load AlbumCovers in strikes mode using multithreading
- (NSMutableArray *) getAlbumsExcluding:(int)ID;

//replacement method to load random AlbumCover in strikes mode using
//data from the progress table to exclude unneeded covers
- (AlbumCover*) getRandomAlbumExcludingLastGame:(NSString *)mode;

//replacement method to load AlbumCovers in strikes mode using multithreading
//and data from the progress table to exclude unneeded covers
- (NSMutableArray *) getAlbumsExcludingLastGame:(NSString *)mode andAlbumID:(int)ID;


//use to get a range of AlbumCovers (meant for levels, but could still be useful for
//new mode
- (NSMutableArray *) getAlbumsAtAlbumID:(int)albumID withLimit:(int)limit;

//only get data pertaining to group of AlbumCovers' visual display.
- (NSMutableArray *) getAlbumCoversAtAlbumID:(int)albumID withLimit:(int)limit;

//get all data about a single AlbumCover. Used in GuessViewController.
- (AlbumCover *) getAlbumAtAlbumID:(int)albumID;

//only get data pertaining to single AlbumCovers' visual display. Used in LevelViewController
- (AlbumCover *)getDetailCoverFileAtAlbumID:(int)albumID;

//get large questionCover image
- (UIImage *)getLargeCoverFileAtAlbumID:(int)albumID;

//albumHints & artistHints tables method
- (NSString *)useAlbumHintFor:(NSString *)hint withAlbumID:(int)albumID;
- (NSString *)useArtistHintFor:(NSString *)hint withAlbumID:(int)albumID;

- (void)updateAlbumHintAtAlbumID:(int)albumID toHint:(NSString *)hint;
- (void)updateArtistHintAtAlbumID:(int)albumID toHint:(NSString *)hint;

- (void)resetArtistHints;
- (void)resetAlbumHints;


//albumProgress & artistProgress tables methods


//setters for progress table √
-(void)updateLevelGuessedAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value;
-(void)updateLevelMaxScoreAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value;
-(void)updateStrikeGuessedAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value;
-(void)updateStrikesLeftAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value;
-(void)updateStrikeMaxScoreAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value;


//score tracking functions √
-(int)getTotalLevelsScoreForMode:(NSString *)mode;
-(int)getTotalStrikesScoreForMode:(NSString *)mode;
-(int)getTotalLevelsGuessedForMode:(NSString *)mode;
-(int)getTotalStrikeGuessedForMode:(NSString *)mode;
-(int)getTotalStrikeModifiedForMode:(NSString *)mode;

//reset to default functions √
-(void)resetStrikesInMode:(NSString *)mode;
-(void)resetAllProgress;


//overallStats table methods

//getters and setters √
-(int)getStat:(NSString *)statName;
-(void)setStat:(NSString *)statName toValue:(int)value;

//reset to default function √
-(void)resetAllStats;


//achievements table methods

//check achievement requirement against progress made √
-(BOOL)requirementsMetFor:(NSString *)name withValue:(int)value;

//getters and setters √
-(int)getAchievementStateFor:(NSString *)name;
-(void)setAchievement:(NSString *)name toState:(int)state;

//reset to default function √
-(void)resetAllAchievements;


//highscores table methods
- (NSMutableArray *) getHighscores;

- (int)getMaxHighscoreID;

- (void)clearHighscoresList;
- (void)addHighscoreWithName:(NSString *)name Score:(int)score andMode:(NSString *)mode;

- (BOOL)highscoreListIsEmpty;
- (BOOL)verifyAsHighscore:(int)score;


//settings table methods
- (int)getSetting:(NSString *)settingName;
- (void)setSetting:(NSString *)settingName toValue:(int)value;


//productIDMappings & productsTable methods
- (NSMutableArray *)getIProductIDs;
- (int)getAppProductIDWithiTunesProductID:(NSString *)iProductID;
- (int)getCategoryIDWithiTunesProductID:(NSString *)iProductID;
- (NSString *)getProductNameWithiTunesProductID:(NSString *)iProductID;
- (NSString *)getProductTypeWithiTunesProductID:(NSString *)iProductID;
- (NSString *)getProductPriceWithiTunesProductID:(NSString *)iProductID;
- (int)getProductPurchaseMadeWithiTunesProductID:(NSString *)iProductID;
- (void)setProductPurchaseMadeWithiTunesProductID:(NSString *)iProductID toValue:(int)value;

@end
