//
//  DBAccess.m
//  AlbumsForiPhone7
//
//  Created by Clay Jacobs2 on 9/25/13.
//  Copyright (c) 2013 CJDev. All rights reserved.
//

#import "DBAccess.h"
#import "AlbumCover.h"

@implementation DBAccess

#pragma mark Class functions

+ (NSString *) getDBPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"AlbumsDatabase.sql"];
}

+ (void) copyDatabaseIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError * error;
    NSString *dbPath = [DBAccess getDBPath];
    
    BOOL success = [fileManager fileExistsAtPath:dbPath];
    
    if (!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlbumsDatabase.sql"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
        
        
        if (!success) {
            NSAssert(0, @"Failed to create writable database file with message '%@'", [error localizedDescription]);
        }
    }
}

#pragma mark Database Query functions

- (NSMutableArray *) getAlbums
{
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //sqlite3_exec(database, "BEGIN", 0, 0, 0);
    
    //albumCovers sql
    NSString *sqlAlbums = @"SELECT `albumID`, `questionCover`, `answerCover` FROM `albumCovers`";
    // albumID| questionCover| answerCover
    //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
    sqlite3_stmt * statementAlbums;
    
    int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
    
    
    if(sqlResultAlbums == SQLITE_OK)
    {
        
        
        
        while (sqlite3_step(statementAlbums) == SQLITE_ROW)
        {
            AlbumCover *cover = [[AlbumCover alloc] init];
            
            NSString *questionCoverFile;
            NSString *answerCoverFile;
            
            //change
            if(IS_IPHONE5) {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
            } else {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                
            }
            
            
            // Set questionCover
            [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
            
            
            // Set answerCover
            [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
            
            
            // Set answers array
            NSMutableArray *albumAnswersArray = [NSMutableArray array];
            
            int albumID = sqlite3_column_int(statementAlbums, 0);
            
            //NSLog(@"%d", albumID);
            
            //albumAnswers sql
            NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAnswers;
            
            int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
            
            if (sqlResultAnswers == SQLITE_OK)
            {
                while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                {
                    int answerAlbumID = sqlite3_column_int(statementAnswers, 0);
                    
                    if (albumID == answerAlbumID)
                    {
                        [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 1)]];
                    }
                    
                    
                }
            }
            
            sqlite3_reset(statementAnswers);
            sqlite3_finalize(statementAnswers);
            
            [cover setAnswers:albumAnswersArray];
            
            
            //set artists array
            NSMutableArray *albumArtistsArray = [NSMutableArray array];
            
            NSString *sqlArtists = [NSString stringWithFormat:@"SELECT albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtists;
            
            int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
            
            if (sqlResultArtists == SQLITE_OK)
            {
                while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                    
                    int artistAlbumID = sqlite3_column_int(statementArtists, 0);
                    
                    if(artistAlbumID == albumID) {
                        [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 1)]];
                    }
                }
            }
            
            sqlite3_reset(statementArtists);
            sqlite3_finalize(statementArtists);
            
            [cover setArtists:albumArtistsArray];
            
            //add cover to result array
            [result addObject:cover];
        }
        
        
    } else
    {
        result = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    //sqlite3_exec(database, "COMMIT", 0, 0, 0);
    
    sqlite3_close(database);
    
    return result;
    
}

- (NSMutableArray *) getAlbumsExcluding:(int)ID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //sqlite3_exec(database, "BEGIN", 0, 0, 0);
    
    //albumCovers sql
    NSString *sqlAlbums = @"SELECT `albumID`, `questionCover`, `answerCover` FROM `albumCovers`";
    // albumID| questionCover| answerCover
    //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
    sqlite3_stmt * statementAlbums;
    
    int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
    
    
    if(sqlResultAlbums == SQLITE_OK)
    {
        
        
        
        while (sqlite3_step(statementAlbums) == SQLITE_ROW)
        {
            AlbumCover *cover = [[AlbumCover alloc] init];
            
            NSString *questionCoverFile;
            NSString *answerCoverFile;
            
            //change
            if(IS_IPHONE5) {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
            } else {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                
            }
            
            
            // Set questionCover
            [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
            
            
            // Set answerCover
            [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
            
            
            // Set answers array
            NSMutableArray *albumAnswersArray = [NSMutableArray array];
            
            int albumID = sqlite3_column_int(statementAlbums, 0);
            
            //NSLog(@"%d", albumID);
            
            //albumAnswers sql
            NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAnswers;
            
            int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
            
            if (sqlResultAnswers == SQLITE_OK)
            {
                while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                {
                    int answerAlbumID = sqlite3_column_int(statementAnswers, 0);
                    
                    if (albumID == answerAlbumID)
                    {
                        [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 1)]];
                    }
                    
                    
                }
            }
            
            sqlite3_reset(statementAnswers);
            sqlite3_finalize(statementAnswers);
            
            [cover setAnswers:albumAnswersArray];
            
            
            //set artists array
            NSMutableArray *albumArtistsArray = [NSMutableArray array];
            
            NSString *sqlArtists = [NSString stringWithFormat:@"SELECT albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtists;
            
            int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
            
            if (sqlResultArtists == SQLITE_OK)
            {
                while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                    
                    int artistAlbumID = sqlite3_column_int(statementArtists, 0);
                    
                    if(artistAlbumID == albumID) {
                        [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 1)]];
                    }
                }
            }
            
            sqlite3_reset(statementArtists);
            sqlite3_finalize(statementArtists);
            
            [cover setArtists:albumArtistsArray];
            
            
            //get strikes from album progress
            int albumStrikesGuessed, albumStrikesLeft, albumStrikesScore;
            albumStrikesGuessed = albumStrikesLeft = albumStrikesScore = 0;
            
            NSString *sqlAlbumProgress = [NSString stringWithFormat:@"SELECT strikeGuessed, strikesLeft, strikeMaxScore FROM albumProgress WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAlbumProgress;
            
            int sqlResultAlbumProgress = sqlite3_prepare(database, [sqlAlbumProgress UTF8String], -1, &statementAlbumProgress, NULL);
            
            if (sqlResultAlbumProgress == SQLITE_OK) {
                while (sqlite3_step(statementAlbumProgress) == SQLITE_ROW) {
                    
                    albumStrikesGuessed = sqlite3_column_int(statementAlbumProgress, 0);
                    albumStrikesLeft = sqlite3_column_int(statementAlbumProgress, 1);
                    albumStrikesScore = sqlite3_column_int(statementAlbumProgress, 2);
                }
            }
        
            
            sqlite3_reset(statementAlbumProgress);
            sqlite3_finalize(statementAlbumProgress);
            
            [cover setAlbumStrikesGuessed:[NSNumber numberWithInt:albumStrikesGuessed]];
            [cover setAlbumStrikesLeft:[NSNumber numberWithInt:albumStrikesLeft]];
            [cover setAlbumStrikesScore:[NSNumber numberWithInt:albumStrikesScore]];
            
            
            
            //get strikes from artist progress
            int artistStrikesGuessed, artistStrikesLeft, artistStrikesScore;
            artistStrikesGuessed = artistStrikesLeft = artistStrikesScore = 0;
            
            NSString *sqlArtistProgress = [NSString stringWithFormat:@"SELECT strikeGuessed, strikesLeft, strikeMaxScore FROM artistProgress WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtistProgress;
            
            int sqlResultArtistProgress = sqlite3_prepare(database, [sqlArtistProgress UTF8String], -1, &statementArtistProgress, NULL);
            
            if (sqlResultArtistProgress == SQLITE_OK) {
                while (sqlite3_step(statementArtistProgress) == SQLITE_ROW) {
                    
                    artistStrikesGuessed = sqlite3_column_int(statementArtistProgress, 0);
                    artistStrikesLeft = sqlite3_column_int(statementArtistProgress, 1);
                    artistStrikesScore = sqlite3_column_int(statementArtistProgress, 2);
                }
            }
            
            
            sqlite3_reset(statementArtistProgress);
            sqlite3_finalize(statementArtistProgress);
            
            [cover setArtistStrikesGuessed:[NSNumber numberWithInt:artistStrikesGuessed]];
            [cover setArtistStrikesLeft:[NSNumber numberWithInt:artistStrikesLeft]];
            [cover setArtistStrikesScore:[NSNumber numberWithInt:artistStrikesScore]];
            
        
            //set albumID
            [cover setAlbumID:[NSNumber numberWithInt:albumID]];
            
            //add cover to result array
            if(ID != albumID) {
                [result addObject:cover];
            }
        }
        
        
    } else
    {
        result = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    //sqlite3_exec(database, "COMMIT", 0, 0, 0);
    
    sqlite3_close(database);
    
    return result;

}


//replacement method to load AlbumCovers in strikes mode using multithreading
//and data from the progress table to exclude unneeded covers
- (NSMutableArray *) getAlbumsExcludingLastGame:(NSString *)mode andAlbumID:(int)ID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];

    
    NSString *sqlExclude;
    if ([mode isEqualToString:@"albums"]) {
        sqlExclude = [NSString stringWithFormat:@"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM albumProgress WHERE albumID != %d AND strikesLeft > 0 AND strikeGuessed != 1 ORDER BY albumID ASC", ID];
    } else if([mode isEqualToString:@"artists"]) {
        sqlExclude = [NSString stringWithFormat:@"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM artistProgress WHERE albumID != %d AND strikesLeft > 0 AND strikeGuessed != 1 ORDER BY albumID ASC", ID];
    }
    
    sqlite3_stmt * statementExclude;
    int sqlResultExclude = sqlite3_prepare_v2(database, [sqlExclude UTF8String], -1, &statementExclude, NULL);
    
    if (sqlResultExclude == SQLITE_OK) {
        while (sqlite3_step(statementExclude) == SQLITE_ROW)
        {
            AlbumCover *cover = [[AlbumCover alloc] init];
            
            //set values
            int albumID = sqlite3_column_int(statementExclude, 0);
            int strikeGuessed = sqlite3_column_int(statementExclude, 1);
            int strikesLeft = sqlite3_column_int(statementExclude, 2);
            int strikeMaxScore = sqlite3_column_int(statementExclude, 3);
            
            if ([mode isEqualToString:@"albums"]) {
                
                [cover setAlbumStrikesGuessed:[NSNumber numberWithInt:strikeGuessed]];
                [cover setAlbumStrikesLeft:[NSNumber numberWithInt:strikesLeft]];
                [cover setAlbumStrikesScore:[NSNumber numberWithInt:strikeMaxScore]];
                
            } else if ([mode isEqualToString:@"artists"]) {
                
                [cover setArtistStrikesGuessed:[NSNumber numberWithInt:strikeGuessed]];
                [cover setArtistStrikesLeft:[NSNumber numberWithInt:strikesLeft]];
                [cover setArtistStrikesScore:[NSNumber numberWithInt:strikeMaxScore]];
                
            }
            
            [cover setAlbumID:[NSNumber numberWithInt:albumID]];
            
            
            //get album covers
            
            NSString *sqlAlbums = [NSString stringWithFormat:@"SELECT questionCover, answerCover FROM albumCovers WHERE albumID = %d", albumID];
            // albumID| questionCover| answerCover
            //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
            sqlite3_stmt * statementAlbums;
            
            int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
            
            
            if(sqlResultAlbums == SQLITE_OK)
            {
                
                
                
                while (sqlite3_step(statementAlbums) == SQLITE_ROW)
                {
                    
                    NSString *questionCoverFile;
                    NSString *answerCoverFile;
                    
                    //change
                    if(IS_IPHONE5) {
                        
                        questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 0)];
                        questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                        
                        answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                        answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                        
                    } else {
                        
                        questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 0)];
                        answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                        
                    }
                    
                    
                    // Set questionCover
                    [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
                    
                    
                    // Set answerCover
                    [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
                }
            }
            
            
            if ([mode isEqualToString:@"albums"]) {
                //set album answers
                NSMutableArray *albumAnswersArray = [NSMutableArray array];
                
                //albumAnswers sql
                NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
                sqlite3_stmt * statementAnswers;
                
                int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
                
                if (sqlResultAnswers == SQLITE_OK)
                {
                    while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                    {
                        int answerAlbumID = sqlite3_column_int(statementAnswers, 0);
                        
                        if (albumID == answerAlbumID)
                        {
                            [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 1)]];
                        }
                        
                        
                    }
                }
                
                sqlite3_reset(statementAnswers);
                sqlite3_finalize(statementAnswers);
                
                [cover setAnswers:albumAnswersArray];
                
            } else if ([mode isEqualToString:@"artists"]) {
                //set artist answers
                NSMutableArray *albumArtistsArray = [NSMutableArray array];
                
                NSString *sqlArtists = [NSString stringWithFormat:@"SELECT albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
                sqlite3_stmt * statementArtists;
                
                int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
                
                if (sqlResultArtists == SQLITE_OK)
                {
                    while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                        
                        int artistAlbumID = sqlite3_column_int(statementArtists, 0);
                        
                        if(artistAlbumID == albumID) {
                            [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 1)]];
                        }
                    }
                }
                
                sqlite3_reset(statementArtists);
                sqlite3_finalize(statementArtists);
                
                [cover setArtists:albumArtistsArray];
                
            }
            
            [result addObject:cover];
        }
    } else
    {
        result = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementExclude);
    sqlite3_finalize(statementExclude);
    
    sqlite3_close(database);
    
    return result;

}


//replacement method to load random AlbumCover in strikes mode using
//data from the progress table to exclude unneeded covers
- (AlbumCover *) getRandomAlbumExcludingLastGame:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    AlbumCover *cover = [[AlbumCover alloc] init];
    
    NSString *sqlExclude;
    if ([mode isEqualToString:@"albums"]) {
        sqlExclude = @"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM albumProgress WHERE strikesLeft > 0 AND strikeGuessed != 1 ORDER BY RANDOM() LIMIT 1";
    } else if([mode isEqualToString:@"artists"]) {
        sqlExclude = @"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM artistProgress WHERE strikesLeft > 0 AND strikeGuessed != 1 ORDER BY RANDOM() LIMIT 1";
    }
    
    sqlite3_stmt * statementExclude;
    int sqlResultExclude = sqlite3_prepare_v2(database, [sqlExclude UTF8String], -1, &statementExclude, NULL);
    
    if (sqlResultExclude == SQLITE_OK) {
        while (sqlite3_step(statementExclude) == SQLITE_ROW)
        {
            //set values
            int albumID = sqlite3_column_int(statementExclude, 0);
            int strikeGuessed = sqlite3_column_int(statementExclude, 1);
            int strikesLeft = sqlite3_column_int(statementExclude, 2);
            int strikeMaxScore = sqlite3_column_int(statementExclude, 3);
            
            if ([mode isEqualToString:@"albums"]) {
                
                [cover setAlbumStrikesGuessed:[NSNumber numberWithInt:strikeGuessed]];
                [cover setAlbumStrikesLeft:[NSNumber numberWithInt:strikesLeft]];
                [cover setAlbumStrikesScore:[NSNumber numberWithInt:strikeMaxScore]];
                
            } else if ([mode isEqualToString:@"artists"]) {
                
                [cover setArtistStrikesGuessed:[NSNumber numberWithInt:strikeGuessed]];
                [cover setArtistStrikesLeft:[NSNumber numberWithInt:strikesLeft]];
                [cover setArtistStrikesScore:[NSNumber numberWithInt:strikeMaxScore]];
                
            }
            
            [cover setAlbumID:[NSNumber numberWithInt:albumID]];
            
            
            //get album covers
            
            NSString *sqlAlbums = [NSString stringWithFormat:@"SELECT questionCover, answerCover FROM albumCovers WHERE albumID = %d", albumID];
            // albumID| questionCover| answerCover
            //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
            sqlite3_stmt * statementAlbums;
            
            int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
            
            
            if(sqlResultAlbums == SQLITE_OK)
            {
                
                
                
                while (sqlite3_step(statementAlbums) == SQLITE_ROW)
                {
                   
                    NSString *questionCoverFile;
                    NSString *answerCoverFile;
                    
                    //change
                    if(IS_IPHONE5) {
                        
                        questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 0)];
                        questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                        
                        answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                        answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                        
                    } else {
                        
                        questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 0)];
                        answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                        
                    }
                
                    
                    // Set questionCover
                    [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
                    
                    
                    // Set answerCover
                    [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
                }
            }

            
            if ([mode isEqualToString:@"albums"]) {
                //set album answers
                NSMutableArray *albumAnswersArray = [NSMutableArray array];
                
                //albumAnswers sql
                NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
                sqlite3_stmt * statementAnswers;
                
                int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
                
                if (sqlResultAnswers == SQLITE_OK)
                {
                    while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                    {
                        int answerAlbumID = sqlite3_column_int(statementAnswers, 0);
                        
                        if (albumID == answerAlbumID)
                        {
                            [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 1)]];
                        }
                        
                        
                    }
                }
                
                sqlite3_reset(statementAnswers);
                sqlite3_finalize(statementAnswers);
                
                [cover setAnswers:albumAnswersArray];
                
            } else if ([mode isEqualToString:@"artists"]) {
                //set artist answers
                NSMutableArray *albumArtistsArray = [NSMutableArray array];
                
                NSString *sqlArtists = [NSString stringWithFormat:@"SELECT albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
                sqlite3_stmt * statementArtists;
                
                int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
                
                if (sqlResultArtists == SQLITE_OK)
                {
                    while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                        
                        int artistAlbumID = sqlite3_column_int(statementArtists, 0);
                        
                        if(artistAlbumID == albumID) {
                            [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 1)]];
                        }
                    }
                }
                
                sqlite3_reset(statementArtists);
                sqlite3_finalize(statementArtists);
                
                [cover setArtists:albumArtistsArray];
                
            }
            
            
        }
    } else
    {
        cover = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementExclude);
    sqlite3_finalize(statementExclude);
    
    sqlite3_close(database);
    
    return cover;
}


- (NSMutableArray *) getAlbumCoversAtAlbumID:(int)albumID withLimit:(int)limit {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    
    
    //albumCovers sql
    NSString *sqlAlbums = [NSString stringWithFormat: @"SELECT `albumID`, `questionCover`, `answerCover` FROM `albumCovers` WHERE `albumID` >= %d LIMIT %d", albumID, limit];
    // albumID| questionCover| answerCover
    //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
    sqlite3_stmt * statementAlbums;
    
    int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
    
    
    if(sqlResultAlbums == SQLITE_OK)
    {
        
        while (sqlite3_step(statementAlbums) == SQLITE_ROW)
        {
            AlbumCover *cover = [[AlbumCover alloc] init];
            
            NSString *questionCoverFile;
            NSString *answerCoverFile;
            
            //change
            if(IS_IPHONE5) {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
            } else {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                
            }
            
            
            // Set questionCover
            [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
            
            
            // Set answerCover
            [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
 
            
            //add cover to result array
            [result addObject:cover];
        }
        
        
    } else
    {
        result = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    sqlite3_close(database);
    
    return result;
    
}

- (NSMutableArray *) getAlbumsAtAlbumID:(int)albumID withLimit:(int)limit {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    
    
    //albumCovers sql
    NSString *sqlAlbums = [NSString stringWithFormat: @"SELECT `albumID`, `questionCover`, `answerCover` FROM `albumCovers` WHERE `albumID` >= %d LIMIT %d", albumID, limit];
    // albumID| questionCover| answerCover
    //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
    sqlite3_stmt * statementAlbums;
    
    int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
    
    
    if(sqlResultAlbums == SQLITE_OK)
    {
        
        
        
        while (sqlite3_step(statementAlbums) == SQLITE_ROW)
        {
            AlbumCover *cover = [[AlbumCover alloc] init];
            
            NSString *questionCoverFile;
            NSString *answerCoverFile;
            
            //change
            if(IS_IPHONE5) {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
            } else {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                
            }
            
            
            // Set questionCover
            [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
            
            
            // Set answerCover
            [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
            
            
            // Set answers array
            NSMutableArray *albumAnswersArray = [NSMutableArray array];
            
            int albumID = sqlite3_column_int(statementAlbums, 0);
            
            //NSLog(@"%d", albumID);
            
            //albumAnswers sql
            NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT answerID, albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAnswers;
            
            int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
            
            if (sqlResultAnswers == SQLITE_OK)
            {
                while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                {
                    int answerAlbumID = sqlite3_column_int(statementAnswers, 1);
                    
                    if (albumID == answerAlbumID)
                    {
                        [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 2)]];
                    }
                    
                    
                }
            }
            
            sqlite3_reset(statementAnswers);
            sqlite3_finalize(statementAnswers);
            
            [cover setAnswers:albumAnswersArray];
            
            
            //set artists array
            NSMutableArray *albumArtistsArray = [NSMutableArray array];
            
            NSString *sqlArtists = [NSString stringWithFormat:@"SELECT answerID, albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtists;
            
            int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
            
            if (sqlResultArtists == SQLITE_OK)
            {
                while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                    
                    int artistAlbumID = sqlite3_column_int(statementArtists, 1);
                    
                    if(artistAlbumID == albumID) {
                        [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 2)]];
                    }
                }
            }
            
            sqlite3_reset(statementArtists);
            sqlite3_finalize(statementArtists);
            
            [cover setArtists:albumArtistsArray];
            
            //add cover to result array
            [result addObject:cover];
        }
        
        
    } else
    {
        result = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    sqlite3_close(database);
    
    return result;
}

- (AlbumCover *) getAlbumAtAlbumID:(int)albumID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    AlbumCover *cover = [[AlbumCover alloc] init];
    
    
    
    //albumCovers sql
    NSString *sqlAlbums = [NSString stringWithFormat: @"SELECT `albumID`, `questionCover`, `answerCover` FROM `albumCovers` WHERE `albumID` >= %d LIMIT 1", albumID];
    // albumID| questionCover| answerCover
    //NSString *sqlAlbums = @"SELECT * FROM albumAnswers";
    sqlite3_stmt * statementAlbums;
    
    int sqlResultAlbums = sqlite3_prepare_v2(database, [sqlAlbums UTF8String], -1, &statementAlbums, NULL);
    
    
    if(sqlResultAlbums == SQLITE_OK)
    {
        
        
        
        while (sqlite3_step(statementAlbums) == SQLITE_ROW)
        {
            
            NSString *questionCoverFile;
            NSString *answerCoverFile;
            
            //change
            if(IS_IPHONE5) {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                questionCoverFile =[questionCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                answerCoverFile = [answerCoverFile stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
                
            } else {
                
                questionCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 1)];
                answerCoverFile = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbums, 2)];
                
            }
            
            
            // Set questionCover
            [cover setQuestionCover:[UIImage imageNamed:questionCoverFile]];
            
            
            // Set answerCover
            [cover setAnswerCover:[UIImage imageNamed:answerCoverFile]];
            
            
            // Set answers array
            NSMutableArray *albumAnswersArray = [NSMutableArray array];
            
            int albumID = sqlite3_column_int(statementAlbums, 0);
            
            //NSLog(@"%d", albumID);
            
            //albumAnswers sql
            NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT answerID, albumID, answer FROM albumAnswers WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAnswers;
            
            int sqlResultAnswers = sqlite3_prepare(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
            
            if (sqlResultAnswers == SQLITE_OK)
            {
                while (sqlite3_step(statementAnswers) == SQLITE_ROW)
                {
                    int answerAlbumID = sqlite3_column_int(statementAnswers, 1);
                    
                    if (albumID == answerAlbumID)
                    {
                        [albumAnswersArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 2)]];
                    }
                    
                    
                }
            }
            
            sqlite3_reset(statementAnswers);
            sqlite3_finalize(statementAnswers);
            
            [cover setAnswers:albumAnswersArray];
            
            
            //set artists array
            NSMutableArray *albumArtistsArray = [NSMutableArray array];
            
            NSString *sqlArtists = [NSString stringWithFormat:@"SELECT answerID, albumID, artist FROM albumArtists WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtists;
            
            int sqlResultArtists = sqlite3_prepare(database, [sqlArtists UTF8String], -1, &statementArtists, NULL);
            
            if (sqlResultArtists == SQLITE_OK)
            {
                while (sqlite3_step(statementArtists) == SQLITE_ROW) {
                    
                    int artistAlbumID = sqlite3_column_int(statementArtists, 1);
                    
                    if(artistAlbumID == albumID) {
                        [albumArtistsArray addObject:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtists, 2)]];
                    }
                }
            }
            
            sqlite3_reset(statementArtists);
            sqlite3_finalize(statementArtists);
            
            [cover setArtists:albumArtistsArray];
            
            
            //albumHints sql
            NSString *sqlAlbumHints = [NSString stringWithFormat:@"SELECT albumID, answerID, albumHint, albumHintDefault FROM albumHints WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAlbumHints;
            
            int sqlResultAlbumHints = sqlite3_prepare(database, [sqlAlbumHints UTF8String], -1, &statementAlbumHints, NULL);
            
            if (sqlResultAlbumHints == SQLITE_OK) {
                while (sqlite3_step(statementAlbumHints) == SQLITE_ROW) {
                    
                    [cover setAlbumHint:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAlbumHints, 2)]];
                    
                }
            }
            
            sqlite3_reset(statementAlbumHints);
            sqlite3_finalize(statementAlbumHints);
            
            
            //artistHints sql
            NSString *sqlArtistHints = [NSString stringWithFormat:@"SELECT albumID, answerID, artistHint, artistHintDefault FROM artistHints WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtistHints;
            
            int sqlResultArtistHints = sqlite3_prepare(database, [sqlArtistHints UTF8String], -1, &statementArtistHints, NULL);
            
            if (sqlResultArtistHints == SQLITE_OK) {
                while (sqlite3_step(statementArtistHints) == SQLITE_ROW) {
                    
                    [cover setArtistHint:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statementArtistHints, 2)]];
                    
                }
            }
            
            sqlite3_reset(statementArtistHints);
            sqlite3_finalize(statementArtistHints);
            
            //get data from album progress
            int albumLevelsGuessed, albumLevelsScore, albumStrikesGuessed, albumStrikesLeft, albumStrikesScore;
            albumLevelsGuessed = albumLevelsScore = albumStrikesGuessed = albumStrikesLeft = albumStrikesScore = 0;
            
            NSString *sqlAlbumProgress = [NSString stringWithFormat:@"SELECT levelGuessed, levelMaxScore, strikeGuessed, strikesLeft, strikeMaxScore FROM albumProgress WHERE albumID = %d", albumID];
            sqlite3_stmt * statementAlbumProgress;
            
            int sqlResultAlbumProgress = sqlite3_prepare(database, [sqlAlbumProgress UTF8String], -1, &statementAlbumProgress, NULL);
            
            if (sqlResultAlbumProgress == SQLITE_OK) {
                while (sqlite3_step(statementAlbumProgress) == SQLITE_ROW) {
                    
                    albumLevelsGuessed = sqlite3_column_int(statementAlbumProgress, 0);
                    albumLevelsScore = sqlite3_column_int(statementAlbumProgress, 1);
                    albumStrikesGuessed = sqlite3_column_int(statementAlbumProgress, 2);
                    albumStrikesLeft = sqlite3_column_int(statementAlbumProgress, 3);
                    albumStrikesScore = sqlite3_column_int(statementAlbumProgress, 4);
                }
            }
            
            
            sqlite3_reset(statementAlbumProgress);
            sqlite3_finalize(statementAlbumProgress);
            
            [cover setAlbumLevelsGuessed:[NSNumber numberWithInt:albumLevelsGuessed]];
            [cover setAlbumLevelsScore:[NSNumber numberWithInt:albumLevelsScore]];
            [cover setAlbumStrikesGuessed:[NSNumber numberWithInt:albumStrikesGuessed]];
            [cover setAlbumStrikesLeft:[NSNumber numberWithInt:albumStrikesLeft]];
            [cover setAlbumStrikesScore:[NSNumber numberWithInt:albumStrikesScore]];
            
            
            
            //get data from artist progress
            int artistLevelsGuessed, artistLevelsScore, artistStrikesGuessed, artistStrikesLeft, artistStrikesScore;
            artistLevelsGuessed = artistLevelsScore = artistStrikesGuessed = artistStrikesLeft = artistStrikesScore = 0;
            
            NSString *sqlArtistProgress = [NSString stringWithFormat:@"SELECT levelGuessed, levelMaxScore, strikeGuessed, strikesLeft, strikeMaxScore FROM artistProgress WHERE albumID = %d", albumID];
            sqlite3_stmt * statementArtistProgress;
            
            int sqlResultArtistProgress = sqlite3_prepare(database, [sqlArtistProgress UTF8String], -1, &statementArtistProgress, NULL);
            
            if (sqlResultArtistProgress == SQLITE_OK) {
                while (sqlite3_step(statementArtistProgress) == SQLITE_ROW) {
                    
                    artistLevelsGuessed = sqlite3_column_int(statementArtistProgress, 0);
                    artistLevelsScore = sqlite3_column_int(statementArtistProgress, 1);
                    artistStrikesGuessed = sqlite3_column_int(statementArtistProgress, 2);
                    artistStrikesLeft = sqlite3_column_int(statementArtistProgress, 3);
                    artistStrikesScore = sqlite3_column_int(statementArtistProgress, 4);
                }
            }
            
            
            sqlite3_reset(statementArtistProgress);
            sqlite3_finalize(statementArtistProgress);
            
            [cover setArtistLevelsGuessed:[NSNumber numberWithInt:artistLevelsGuessed]];
            [cover setArtistLevelsScore:[NSNumber numberWithInt:artistLevelsScore]];
            [cover setArtistStrikesGuessed:[NSNumber numberWithInt:artistStrikesGuessed]];
            [cover setArtistStrikesLeft:[NSNumber numberWithInt:artistStrikesLeft]];
            [cover setArtistStrikesScore:[NSNumber numberWithInt:artistStrikesScore]];
            
            
            //set albumID
            [cover setAlbumID:[NSNumber numberWithInt:albumID]];

        }
        
        
    } else
    {
        cover = nil;
        printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
    }
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    sqlite3_close(database);

    return cover;
}


- (AlbumCover *)getDetailCoverFileAtAlbumID:(int)albumID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    AlbumCover *cover = [[AlbumCover alloc] init];
    
    //make database query
    NSString *sql = [NSString stringWithFormat:@"SELECT questionCover, answerCover FROM albumCovers WHERE albumID = %d", albumID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *question = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            NSString *answer = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            question = [question stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
            answer = [answer stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
            
            [cover setQuestionCover:[UIImage imageNamed:question]];
            
            [cover setQuestionCover:[UIImage imageNamed:answer]];
            
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    //get levelGuessed from album progress
    int albumLevelsGuessed;
    albumLevelsGuessed = 0;
    
    NSString *sqlAlbumProgress = [NSString stringWithFormat:@"SELECT levelGuessed FROM albumProgress WHERE albumID = %d", albumID];
    sqlite3_stmt * statementAlbumProgress;
    
    int sqlResultAlbumProgress = sqlite3_prepare(database, [sqlAlbumProgress UTF8String], -1, &statementAlbumProgress, NULL);
    
    if (sqlResultAlbumProgress == SQLITE_OK) {
        while (sqlite3_step(statementAlbumProgress) == SQLITE_ROW) {
            
            albumLevelsGuessed = sqlite3_column_int(statementAlbumProgress, 0);
        }
    }
    
    
    sqlite3_reset(statementAlbumProgress);
    sqlite3_finalize(statementAlbumProgress);
    
    [cover setAlbumLevelsGuessed:[NSNumber numberWithInt:albumLevelsGuessed]];
    
    
    
    //get levelGuessed from artist progress
    int artistLevelsGuessed;
    artistLevelsGuessed = 0;
    
    NSString *sqlArtistProgress = [NSString stringWithFormat:@"SELECT levelGuessed FROM artistProgress WHERE albumID = %d", albumID];
    sqlite3_stmt * statementArtistProgress;
    
    int sqlResultArtistProgress = sqlite3_prepare(database, [sqlArtistProgress UTF8String], -1, &statementArtistProgress, NULL);
    
    if (sqlResultArtistProgress == SQLITE_OK) {
        while (sqlite3_step(statementArtistProgress) == SQLITE_ROW) {
            
            artistLevelsGuessed = sqlite3_column_int(statementArtistProgress, 0);

        }
    }
    
    
    sqlite3_reset(statementArtistProgress);
    sqlite3_finalize(statementArtistProgress);
    
    [cover setArtistLevelsGuessed:[NSNumber numberWithInt:artistLevelsGuessed]];
    
    
    sqlite3_close(database);
    
    return cover;
    
}

- (UIImage *)getLargeCoverFileAtAlbumID:(int)albumID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    UIImage *cover;
    
    //make database query
    NSString *sql = [NSString stringWithFormat:@"SELECT questionCover FROM albumCovers WHERE albumID = %d", albumID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *question = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            question = [question stringByReplacingOccurrencesOfString:@".jpg" withString:@"@2x.jpg"];
            //NSString *answer = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
            
            cover = [UIImage imageNamed:question];
            
            //NSLog(question);
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return cover;
    
}


#pragma mark hintsTable methods

/*store answerID in answerID, then use the answerID to get the
 *answer and store in albumAnswer
 *compare hint with albumAnswer until we find a missing character.
 *add missing letter to hint string*/
- (NSString *)useAlbumHintFor:(NSString *)hint withAlbumID:(int)albumID {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int answerID = -1;
    NSString *albumAnswer;
    
    //query albumHints
    NSString *sqlHints = [NSString stringWithFormat:@"SELECT answerID FROM albumHints WHERE albumID = %d", albumID];
    sqlite3_stmt * statementHints;
    int sqlHintsResult = sqlite3_prepare_v2(database, [sqlHints UTF8String], -1, &statementHints, NULL);
    
    if(sqlHintsResult == SQLITE_OK) {
        while (sqlite3_step(statementHints) == SQLITE_ROW) {
            answerID = sqlite3_column_int(statementHints, 0);
        }
    }
    
    sqlite3_reset(statementHints);
    sqlite3_finalize(statementHints);
    
    
    //query albumAnswers
    NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT answer FROM albumAnswers WHERE answerID = %d", answerID];
    sqlite3_stmt * statementAnswers;
    int sqlAnswersResult = sqlite3_prepare_v2(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
    
    if(sqlAnswersResult == SQLITE_OK) {
        while (sqlite3_step(statementAnswers) == SQLITE_ROW) {
            albumAnswer = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 0)];
        }
    }
    
    sqlite3_reset(statementAnswers);
    sqlite3_finalize(statementAnswers);
    
    
    //close database
    sqlite3_close(database);
    
    
    //compare strings partial strings
    NSRange location = [hint rangeOfString:@"_ "];
    NSLog(@"%@", hint);
    
    if(location.location != NSNotFound) {
        NSString *insertionString = [NSString stringWithFormat:@"%c", [albumAnswer characterAtIndex:location.location]];
        
        
        NSString *temp = [hint stringByReplacingCharactersInRange:location withString:insertionString];
        NSLog(@"%@", temp);
        return temp;
    } else {
        return hint;
    }
    
    
}


- (NSString *)useArtistHintFor:(NSString *)hint withAlbumID:(int)albumID {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int answerID = -1;
    NSString *artistAnswer;
    
    //query artistHints
    NSString *sqlHints = [NSString stringWithFormat:@"SELECT answerID FROM artistHints WHERE albumID = %d", albumID];
    sqlite3_stmt * statementHints;
    int sqlHintsResult = sqlite3_prepare_v2(database, [sqlHints UTF8String], -1, &statementHints, NULL);
    
    if(sqlHintsResult == SQLITE_OK) {
        while (sqlite3_step(statementHints) == SQLITE_ROW) {
            answerID = sqlite3_column_int(statementHints, 0);
        }
    }
    
    sqlite3_reset(statementHints);
    sqlite3_finalize(statementHints);

    
    //query albumArtists
    NSString *sqlAnswers = [NSString stringWithFormat:@"SELECT artist FROM albumArtists WHERE answerID = %d", answerID];
    sqlite3_stmt * statementAnswers;
    int sqlAnswersResult = sqlite3_prepare_v2(database, [sqlAnswers UTF8String], -1, &statementAnswers, NULL);
    
    if(sqlAnswersResult == SQLITE_OK) {
        while (sqlite3_step(statementAnswers) == SQLITE_ROW) {
            artistAnswer = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementAnswers, 0)];
        }
    }
    
    sqlite3_reset(statementAnswers);
    sqlite3_finalize(statementAnswers);


    //close database
    sqlite3_close(database);
    
    
    NSRange location = [hint rangeOfString:@"_ "];
    NSLog(@"%@", hint);
    
    if(location.location != NSNotFound) {
        NSString *insertionString = [NSString stringWithFormat:@"%c", [artistAnswer characterAtIndex:location.location]];


        NSString *temp = [hint stringByReplacingCharactersInRange:location withString:insertionString];
        NSLog(@"%@", temp);
        return temp;
    } else {
        return hint;
    }
    

}


- (void)updateAlbumHintAtAlbumID:(int)albumID toHint:(NSString *)hint{
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    
    //update query
    NSString *sqlAlbumUpdate = [NSString stringWithFormat:@"UPDATE albumHints SET albumHint = \"%@\" WHERE albumID = %d", hint, albumID];
    sqlite3_stmt * statementAlbumUpdate;
    sqlite3_prepare_v2(database, [sqlAlbumUpdate UTF8String], -1, &statementAlbumUpdate, NULL);
    

    if(sqlite3_step(statementAlbumUpdate) == SQLITE_DONE){
        
        NSLog(@"User Update was succesfull");
    }
    
    sqlite3_reset(statementAlbumUpdate);
    sqlite3_finalize(statementAlbumUpdate);

    
    
    //TODO: add update for overallStats totalHints
 
    
    //close database
    sqlite3_close(database);
}


- (void)updateArtistHintAtAlbumID:(int)albumID toHint:(NSString *)hint{
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    
    //update query
    NSString *sqlArtistUpdate = [NSString stringWithFormat:@"UPDATE artistHints SET artistHint = \"%@\" WHERE albumID = %d", hint, albumID];
    sqlite3_stmt * statementArtistUpdate;
    sqlite3_prepare_v2(database, [sqlArtistUpdate UTF8String], -1, &statementArtistUpdate, NULL);
    
    
    if(sqlite3_step(statementArtistUpdate) == SQLITE_DONE){
        
        NSLog(@"User Update was succesfull");
    }
    
    sqlite3_reset(statementArtistUpdate);
    sqlite3_finalize(statementArtistUpdate);
    
    
    
    //TODO: add update for overallStats totalHints
    
    
    //close database
    sqlite3_close(database);
    
}


/*if any artistHints and artistHintDefaults don't match up,
 *then set the artistHints to the default*/
- (void)resetArtistHints {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSString *artistHint;
    NSString *artistHintDefault;
    int albumID;
    
    
    //select all from hints table
    NSString *sqlHints = @"SELECT albumID, artistHint, artistHintDefault FROM artistHints";
    sqlite3_stmt * statementHints;
    int sqlHintsResult = sqlite3_prepare_v2(database, [sqlHints UTF8String], -1, &statementHints, NULL);
    
    if(sqlHintsResult == SQLITE_OK) {
        while (sqlite3_step(statementHints) == SQLITE_ROW) {
            albumID = sqlite3_column_int(statementHints, 0);
            artistHint = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementHints, 1)];
            artistHintDefault = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementHints, 2)];
            
            //perform update query if hint and hintDefault aren't the same
            if (![artistHint isEqualToString:artistHintDefault]) {
                
                //update query
                NSString *sqlArtistUpdate = [NSString stringWithFormat:@"UPDATE artistHints SET artistHint = \"%@\" WHERE albumID = %d", artistHintDefault, albumID];
                sqlite3_stmt * statementArtistUpdate;
                sqlite3_prepare_v2(database, [sqlArtistUpdate UTF8String], -1, &statementArtistUpdate, NULL);
                
                
                if(sqlite3_step(statementArtistUpdate) == SQLITE_DONE){
                    
                    NSLog(@"User Update was succesfull");
                }
                
                sqlite3_reset(statementArtistUpdate);
                sqlite3_finalize(statementArtistUpdate);

                
            }
        }
    }
    
    sqlite3_reset(statementHints);
    sqlite3_finalize(statementHints);

    
    
    //close database
    sqlite3_close(database);
}


/*if any albumHints and albumHintDefaults don't match up,
 *then set the albumHints to the default*/
- (void)resetAlbumHints {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSString *albumHint;
    NSString *albumHintDefault;
    int albumID;
    
    
    //select all from hints table
    NSString *sqlHints = @"SELECT albumID, albumHint, albumHintDefault FROM albumHints";
    sqlite3_stmt * statementHints;
    int sqlHintsResult = sqlite3_prepare_v2(database, [sqlHints UTF8String], -1, &statementHints, NULL);
    
    if(sqlHintsResult == SQLITE_OK) {
        while (sqlite3_step(statementHints) == SQLITE_ROW) {
            albumID = sqlite3_column_int(statementHints, 0);
            albumHint = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementHints, 1)];
            albumHintDefault = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statementHints, 2)];
            
            //perform update query if hint and hintDefault aren't the same
            if (![albumHint isEqualToString:albumHintDefault]) {
                
                //update query
                NSString *sqlAlbumUpdate = [NSString stringWithFormat:@"UPDATE albumHints SET albumHint = \"%@\" WHERE albumID = %d", albumHintDefault, albumID];
                sqlite3_stmt * statementAlbumUpdate;
                sqlite3_prepare_v2(database, [sqlAlbumUpdate UTF8String], -1, &statementAlbumUpdate, NULL);
                
                
                if(sqlite3_step(statementAlbumUpdate) == SQLITE_DONE){
                    
                    NSLog(@"User Update was succesfull");
                }
                
                sqlite3_reset(statementAlbumUpdate);
                sqlite3_finalize(statementAlbumUpdate);

            }
        }
    }
    
    sqlite3_reset(statementHints);
    sqlite3_finalize(statementHints);
    
    
    

    //close database
    sqlite3_close(database);
}

#pragma mark progress table methods

-(void)updateLevelGuessedAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //perform update query
    NSString *update;
    
    if ([mode isEqualToString:@"albums"]) {
        update = [NSString stringWithFormat:@"UPDATE albumProgress SET levelGuessed = %d WHERE albumID = %d", value, albumID];
    } else if ([mode isEqualToString:@"artists"]){
        update = [NSString stringWithFormat:@"UPDATE artistProgress SET levelGuessed = %d WHERE albumID = %d", value, albumID];
    }
    
    sqlite3_stmt * statement;
    sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Successfully updated value of levelGuessed in progress table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}

-(void)updateLevelMaxScoreAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //perform update query
    NSString *update;
    
    if ([mode isEqualToString:@"albums"]) {
        update = [NSString stringWithFormat:@"UPDATE albumProgress SET levelMaxScore = %d WHERE albumID = %d", value, albumID];
    } else if ([mode isEqualToString:@"artists"]){
        update = [NSString stringWithFormat:@"UPDATE artistProgress SET levelMaxScore = %d WHERE albumID = %d", value, albumID];
    }
    
    sqlite3_stmt * statement;
    sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Successfully updated value of levelMaxScore in progress table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}

-(void)updateStrikeGuessedAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //perform update query
    NSString *update;
    
    if ([mode isEqualToString:@"albums"]) {
        update = [NSString stringWithFormat:@"UPDATE albumProgress SET strikeGuessed = %d WHERE albumID = %d", value, albumID];
    } else if ([mode isEqualToString:@"artists"]){
        update = [NSString stringWithFormat:@"UPDATE artistProgress SET strikeGuessed = %d WHERE albumID = %d", value, albumID];
    }
    
    sqlite3_stmt * statement;
    sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Successfully updated value of strikeGuessed in progress table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);

}

-(void)updateStrikesLeftAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value{
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //perform update query
    NSString *update;
    
    if ([mode isEqualToString:@"albums"]) {
        update = [NSString stringWithFormat:@"UPDATE albumProgress SET strikesLeft = %d WHERE albumID = %d", value, albumID];
    } else if ([mode isEqualToString:@"artists"]){
        update = [NSString stringWithFormat:@"UPDATE artistProgress SET strikesLeft = %d WHERE albumID = %d", value, albumID];
    }
    
    sqlite3_stmt * statement;
    sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Successfully updated value of strikesLeft in progress table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);

}

-(void)updateStrikeMaxScoreAtAlbumID:(int)albumID inMode:(NSString *)mode toValue:(int)value {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //perform update query
    NSString *update;
    
    if ([mode isEqualToString:@"albums"]) {
        update = [NSString stringWithFormat:@"UPDATE albumProgress SET strikeMaxScore = %d WHERE albumID = %d", value, albumID];
    } else if ([mode isEqualToString:@"artists"]){
        update = [NSString stringWithFormat:@"UPDATE artistProgress SET strikeMaxScore = %d WHERE albumID = %d", value, albumID];
    }
    
    sqlite3_stmt * statement;
    sqlite3_prepare_v2(database, [update UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"Successfully updated value of strikeMaxScore in progress table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);

}

/*returns the running score total for levels game*/
-(int)getTotalLevelsScoreForMode:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int runningTotal =0;
    
    //add up running total
    NSString *getSum;
    if ([mode isEqualToString:@"albums"]) {
        getSum = @"SELECT SUM(levelMaxScore) FROM albumProgress WHERE levelGuessed = 1";
    } else if([mode isEqualToString:@"artists"]) {
        getSum = @"SELECT SUM(levelMaxScore) FROM artistProgress WHERE levelGuessed = 1";
    }
    
    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [getSum UTF8String], -1, &statement, NULL);
    
    if(result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            runningTotal = sqlite3_column_int(statement, 0);
        }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return runningTotal;
}

/*returns the running score total for strikes game*/
-(int)getTotalStrikesScoreForMode:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int runningTotal =0;
    
    //add up running total
    NSString *getSum;
    if ([mode isEqualToString:@"albums"]) {
        getSum = @"SELECT SUM(strikeMaxScore) FROM albumProgress WHERE strikeGuessed = 1 OR strikesLeft = 0";
    } else if([mode isEqualToString:@"artists"]) {
        getSum = @"SELECT SUM(strikeMaxScore) FROM artistProgress WHERE strikeGuessed = 1 OR strikesLeft = 0";
    }
    
    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [getSum UTF8String], -1, &statement, NULL);
    
    if(result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            runningTotal = sqlite3_column_int(statement, 0);
        }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return runningTotal;
    
}

/*returns number of albums guessed in total for levels game*/
-(int)getTotalLevelsGuessedForMode:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int count =0;
    
    //add up running total
    NSString *getSum;
    if ([mode isEqualToString:@"albums"]) {
        getSum = @"SELECT COUNT(levelGuessed) FROM albumProgress WHERE levelGuessed = 1";
    } else if([mode isEqualToString:@"artists"]) {
        getSum = @"SELECT COUNT(levelGuessed) FROM artistProgress WHERE levelGuessed = 1";
    }
    
    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [getSum UTF8String], -1, &statement, NULL);
    
    if(result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return count;

}

/*returns number of albums guessed in total for strikes game*/
-(int)getTotalStrikeGuessedForMode:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int count =0;
    
    //add up running total
    NSString *getSum;
    if ([mode isEqualToString:@"albums"]) {
        getSum = @"SELECT COUNT(strikeGuessed) FROM albumProgress WHERE strikeGuessed = 1 OR strikesLeft = 0";
    } else if([mode isEqualToString:@"artists"]) {
        getSum = @"SELECT COUNT(strikeGuessed) FROM artistProgress WHERE strikeGuessed = 1 OR strikesLeft = 0";
    }
    
    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [getSum UTF8String], -1, &statement, NULL);
    
    if(result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return count;
    
}

/*returns number of albums modified in total for strikes game*/
-(int)getTotalStrikeModifiedForMode:(NSString *)mode {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int count =0;
    
    //add up running total
    NSString *getSum;
    if ([mode isEqualToString:@"albums"]) {
        getSum = @"SELECT COUNT(strikeGuessed) FROM albumProgress WHERE strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
    } else if([mode isEqualToString:@"artists"]) {
        getSum = @"SELECT COUNT(strikeGuessed) FROM artistProgress WHERE strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
    }
    
    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [getSum UTF8String], -1, &statement, NULL);
    
    if(result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
    }
    
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return count;

}

/*Resets progress for strikes game modes only*/
-(void)resetStrikesInMode:(NSString *)mode {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    NSString *selectSQL;
    int albumID =0;
    
    int rowCount = 0;
    
    //run select query
    if ([mode isEqualToString:@"albums"]) {
        selectSQL = @"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM albumProgress WHERE strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
        
    }else if([mode isEqualToString:@"artists"]) {
        selectSQL = @"SELECT albumID, strikeGuessed, strikesLeft, strikeMaxScore FROM artistProgress WHERE strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
    }

    sqlite3_stmt * statement;
    int result =sqlite3_prepare_v2(database, [selectSQL UTF8String], -1, &statement, NULL);
    if (result == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            albumID = sqlite3_column_int(statement, 0);
            
            //perform update query
            NSString *updateSQL;
            if ([mode isEqualToString:@"albums"]) {
                updateSQL = [NSString stringWithFormat:@"UPDATE albumProgress SET strikeGuessed = 0, strikesLeft = 3, strikeMaxScore = 100 WHERE albumID = %d", albumID];
            } else if ([mode isEqualToString:@"artists"]) {
                updateSQL = [NSString stringWithFormat:@"UPDATE artistProgress SET strikeGuessed = 0, strikesLeft = 3, strikeMaxScore = 100 WHERE albumID = %d", albumID];
            }
            
            sqlite3_stmt * updateStatement;
            sqlite3_prepare_v2(database, [updateSQL UTF8String], -1, &updateStatement, NULL);
            if(sqlite3_step(updateStatement) == SQLITE_DONE){
                rowCount++;
               
            }

            
            sqlite3_reset(updateStatement);
            sqlite3_finalize(updateStatement);
            
            

        }
    }

    NSLog(@"User Reset %d rows of strikes progress for %@ mode", rowCount, mode);
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}


/*Resets progress for everything*/
-(void)resetAllProgress {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    int albumPRows = 0;
    int artistPRows = 0;
    
    //reset for album progress
    NSString *selectAlbums = @"SELECT * FROM albumProgress WHERE levelGuessed != 0 OR levelMaxScore != 100 OR strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
    
    sqlite3_stmt * statementAlbums;
    int resultAlbums =sqlite3_prepare_v2(database, [selectAlbums UTF8String], -1, &statementAlbums, NULL);
    if (resultAlbums == SQLITE_OK) {
        while (sqlite3_step(statementAlbums) == SQLITE_ROW) {
        
            int albumID = sqlite3_column_int(statementAlbums, 0);
            
            //perform update query
            NSString *updateAlbums = [NSString stringWithFormat:@"UPDATE albumProgress SET levelGuessed = 0, levelMaxScore = 100, strikeGuessed = 0, strikesLeft = 3, strikeMaxScore = 100 WHERE albumID = %d", albumID];
            
            sqlite3_stmt * statementUpdateAlbums;
            sqlite3_prepare_v2(database, [updateAlbums UTF8String], -1, &statementUpdateAlbums, NULL);
            if(sqlite3_step(statementUpdateAlbums) == SQLITE_DONE){
                
                albumPRows++;
                
            }
            
            sqlite3_reset(statementUpdateAlbums);
            sqlite3_finalize(statementUpdateAlbums);
            
        }
    }
    
    
    sqlite3_reset(statementAlbums);
    sqlite3_finalize(statementAlbums);
    
    
    //reset for artist progress
    NSString *selectArtists = @"SELECT * FROM artistProgress WHERE levelGuessed != 0 OR levelMaxScore != 100 OR strikeGuessed != 0 OR strikesLeft != 3 OR strikeMaxScore != 100";
    
    sqlite3_stmt * statementArtists;
    int resultArtists =sqlite3_prepare_v2(database, [selectArtists UTF8String], -1, &statementArtists, NULL);
    if (resultArtists == SQLITE_OK) {
        while (sqlite3_step(statementArtists) == SQLITE_ROW) {
            
            int albumID = sqlite3_column_int(statementArtists, 0);
            
            //perform update query
            NSString *updateArtists = [NSString stringWithFormat:@"UPDATE artistProgress SET levelGuessed = 0, levelMaxScore = 100, strikeGuessed = 0, strikesLeft = 3, strikeMaxScore = 100 WHERE albumID = %d", albumID];
            
            sqlite3_stmt * statementUpdateArtists;
            sqlite3_prepare_v2(database, [updateArtists UTF8String], -1, &statementUpdateArtists, NULL);
            if(sqlite3_step(statementUpdateArtists) == SQLITE_DONE){
                
                artistPRows++;
                
            }
            
            sqlite3_reset(statementUpdateArtists);
            sqlite3_finalize(statementUpdateArtists);
            
        }
    }
    
    
    sqlite3_reset(statementArtists);
    sqlite3_finalize(statementArtists);

    
    NSLog(@"%d rows of Album Progress Reset. %d rows of Artist Progress Reset", albumPRows, artistPRows);
    
    
    sqlite3_close(database);

}


#pragma mark overallStats table methods

-(int)getStat:(NSString *)statName {
    int statValue =-1;
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT statName, totalScore FROM overallStats WHERE statName = '%@'", statName];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    //set return variable
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            statValue = sqlite3_column_int(statement, 1);
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return statValue;
    

}

-(void)setStat:(NSString *)statName toValue:(int)value {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = %d WHERE statName = '%@'", value, statName];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"User updated %@ to %d", statName, value);
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}


-(void)resetAllStats {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int statID = -1;
    int totalScore = -1;

    //select query
    NSString *sqlSelect = @"SELECT statID, totalScore FROM overallStats WHERE statID >= 0";
    sqlite3_stmt * statementSelect;
    int sqlResult = sqlite3_prepare_v2(database, [sqlSelect UTF8String], -1, &statementSelect, NULL);
    
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statementSelect) == SQLITE_ROW) {
            
            statID = sqlite3_column_int(statementSelect, 0);
            totalScore = sqlite3_column_int(statementSelect, 1);
            
            
            NSString *sqlUpdate;
            
            //update query
            if (statID == 0) {
                int purchasedHints = [self getStat:@"purchasedHints"];
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = %d WHERE statID = %d", 25 +purchasedHints, statID];
                NSLog(@"in here %d", purchasedHints);
            }
            else if (statID <= 4 && statID > 0) {
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = 0 WHERE statID = %d", statID];
            }
            else if (statID == 5 || statID == 6) {
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = 3 WHERE statID = %d", statID];
            }
            else if (statID == 7) {
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = 25 WHERE statID = %d", statID];
            }
            else if (statID == 8) {
                //don't get rid of purchased hints until they're all used up
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = 0 WHERE statID = %d", statID];
            }
            else if (statID == 9) {
                //don't get rid of purchased hints until they're all used up
                sqlUpdate = [NSString stringWithFormat:@"UPDATE overallStats SET totalScore = %d WHERE statID = %d", totalScore, statID];
            }

            
            sqlite3_stmt * statementUpdate;
            sqlite3_prepare_v2(database, [sqlUpdate UTF8String], -1, &statementUpdate, NULL);
            
            if (sqlite3_step(statementUpdate) == SQLITE_DONE) {
                NSLog(@"Reset statID %d to %d", statID, totalScore);
            }else
            {
                printf( "could not prepare statement %s\n", sqlite3_errmsg(database));
            }

            
            sqlite3_reset(statementUpdate);
            sqlite3_finalize(statementUpdate);
            
            
        }
    }
    
    sqlite3_reset(statementSelect);
    sqlite3_finalize(statementSelect);
    
    sqlite3_close(database);
    
    
}

#pragma mark achievements table methods

-(BOOL)requirementsMetFor:(NSString *)name withValue:(int)value {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int requirementMet = -1;
    
    //select query
    NSString *sql = [NSString stringWithFormat:@"SELECT achievementID, albumsNeeded FROM achievements WHERE achievementName = '%@'", name];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            int achievementID = sqlite3_column_int(statement, 0);
            int albumsNeeded = sqlite3_column_int(statement, 1);
            
            if (achievementID == 0) {
                //check if another hint has been earned
                
                if (value/albumsNeeded > (value-1)/albumsNeeded) {
                    
                    requirementMet =1;
                }
                else {
                    requirementMet =0;
                }
                
                
            }
            else {
                //check if another level has been unlocked
                if (albumsNeeded == value) {
                    requirementMet =1;
                }
                else {
                    requirementMet =0;
                }
                
            }
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    if (requirementMet == 1) {
        return YES;
    }
    else {
        return NO;
    }
}

-(int)getAchievementStateFor:(NSString *)name {
    int stateValue =-1;
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT achievementState FROM achievements WHERE achievementName = '%@'", name];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    //set return variable
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            stateValue = sqlite3_column_int(statement, 0);
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return stateValue;
}


-(void)setAchievement:(NSString *)name toState:(int)state {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"UPDATE achievements SET achievementState = %d WHERE achievementName = '%@'", state, name];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"User updated %@ to %d", name, state);
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
}


-(void)resetAllAchievements {
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = @"UPDATE achievements SET achievementState = 0 WHERE achievementState != 0";
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"User reset achievements table");
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}



#pragma mark highscores table methods

- (NSMutableArray *)getHighscores {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //make database query
    NSString *sql = @"SELECT highscoreID, score, name, mode FROM highscores";
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    
    //add highscore data to the NSMutableArray as NSStrings
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            //store name and score in NSStrings
            NSString *name = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 2)];
            NSString *score = [NSString stringWithFormat:@"%d", sqlite3_column_int(statement, 1)];
            NSString *mode = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 3)];
            
            //add NSStrings to result
            [result addObject:name];
            [result addObject:score];
            [result addObject:mode];
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return result;
}

/*
 *
 */
- (void)addHighscoreWithName:(NSString *)name Score:(int)score andMode:(NSString *)mode{
    
    //char *error;
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    int hasBeenInserted= 0;
    
    NSLog(@"Ready to add");
    
    if (![self highscoreListIsEmpty]) {
        NSLog(@"Highscore contains highscores");
        // find the right location for new highscore, store to
        // insertionHighScoreID, and shift highscoreIDs to make room for
        // new high score
        int insertionHighScoreID=-1;
        
        //get the maximum high score id
        int maxHighScoreID = [self getMaxHighscoreID];
        
        //make database query
        NSString *sql = @"SELECT highscoreID, score FROM highscores";
        sqlite3_stmt * statement;
        int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
        
        
        //iterate through highscores until we find one that is >= score
        if(sqlResult == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                int checkScore = sqlite3_column_int(statement, 1);
                
                if (score >= checkScore && insertionHighScoreID < 0) {
                    insertionHighScoreID = sqlite3_column_int(statement, 0);
                }
                
            }
        }
        
        
        NSLog(@"insertionHighScoreID: %d", insertionHighScoreID);
        NSLog(@"maxHighScoreID: %d", maxHighScoreID);
        
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        
        
        if (insertionHighScoreID == -1) {
            
            if (maxHighScoreID < 9) {
                
                NSLog(@"maxHighScoreID < 9");
                //make database insertion query
                NSString *sqlInsert = [NSString stringWithFormat:@"INSERT INTO highscores (highscoreID, score, name, mode) VALUES (%d, %d, '%@', '%@')", maxHighScoreID+1, score, name, mode];
                hasBeenInserted = 1;
                sqlite3_stmt * statementInsert;
                int result = sqlite3_prepare_v2(database, [sqlInsert UTF8String], -1, &statementInsert, NULL);
                
                //if(sqlite3_step(statementInsert) == SQLITE_DONE)
                
                if(result == SQLITE_OK) {
                    while (sqlite3_step(statementInsert) == SQLITE_ROW) {
                        NSLog(@"User inserted at highscoreID %d", maxHighScoreID+1);
                    }
                }
                sqlite3_reset(statementInsert);
                sqlite3_finalize(statementInsert);
                
                //sqlite3_close(database);
            }
            
            
        } else if (insertionHighScoreID < maxHighScoreID && insertionHighScoreID > -1) {
            
            NSLog(@"insertionHighScoreID < maxHighScoreID");
            
            
            //run update queries on values from insertionID to maxID
            for (int i = maxHighScoreID; i >= insertionHighScoreID; i--) {
                
                //NSLog(@"%d", i);
                
                if (i == 9) {
                    NSLog(@"i == 9");
                    //make database delete query
                    NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM highscores WHERE highscoreID = %d", i];
                    sqlite3_stmt * statementDelete;
                    sqlite3_prepare_v2(database, [sqlDelete UTF8String], -1, &statementDelete, NULL);
                    
                    NSLog(@"%@", sqlDelete);
                    
                    if(sqlite3_step(statementDelete) == SQLITE_DONE)
                    {
                        NSLog(@"User Deleted highscoreID %d", i);
                    }
                    
                    sqlite3_reset(statementDelete);
                    sqlite3_finalize(statementDelete);
                    
                } else {
                    NSLog(@"i != 9");
                    //make database update query
                    NSString *sqlUpdate = [NSString stringWithFormat:@"UPDATE highscores SET highscoreID = %d WHERE highscoreID = %d", i+1, i];
                    sqlite3_stmt * statementUpdate;
                    sqlite3_prepare_v2(database, [sqlUpdate UTF8String], -1, &statementUpdate, NULL);
                    
                    
                    NSLog(@"%@", sqlUpdate);
                    if(sqlite3_step(statementUpdate) == SQLITE_DONE){
                        
                        NSLog(@"User Updated highscoreID %d to %d", i, i+1);
                    }
                    
                    sqlite3_reset(statementUpdate);
                    sqlite3_finalize(statementUpdate);
                    
                }
            }
            
            
            
        } else if (insertionHighScoreID == maxHighScoreID) {
            if (maxHighScoreID == 9) {
                //make database delete query
                NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM highscores WHERE highscoreID = %d", insertionHighScoreID];
                sqlite3_stmt * statementDelete;
                sqlite3_prepare_v2(database, [sqlDelete UTF8String], -1, &statementDelete, NULL);
                
                if(sqlite3_step(statementDelete) == SQLITE_DONE)
                {
                    NSLog(@"User Deleted highscoreID %d", insertionHighScoreID);
                }
                
                sqlite3_reset(statementDelete);
                sqlite3_finalize(statementDelete);
            } else {
                for (int i = maxHighScoreID; i >= insertionHighScoreID; i--) {
                    
                    if (i >= 9) {
                        //make database delete query
                        NSString *sqlDelete = [NSString stringWithFormat:@"DELETE FROM highscores WHERE highscoreID = %d", i];
                        sqlite3_stmt * statementDelete;
                        sqlite3_prepare_v2(database, [sqlDelete UTF8String], -1, &statementDelete, NULL);
                        
                        if(sqlite3_step(statementDelete) == SQLITE_DONE)
                        {
                            NSLog(@"User Deleted highscoreID %d", insertionHighScoreID);
                        }
                        
                        sqlite3_reset(statementDelete);
                        sqlite3_finalize(statementDelete);
                        
                    } else {
                        //make database update query
                        NSString *sqlUpdate = [NSString stringWithFormat:@"UPDATE highscores SET highscoreID = %d WHERE highscoreID = %d", i+1, i];
                        sqlite3_stmt * statementUpdate;
                        sqlite3_prepare_v2(database, [sqlUpdate UTF8String], -1, &statementUpdate, NULL);
                        
                        
                        if(sqlite3_step(statementUpdate) == SQLITE_DONE)
                        {
                            NSLog(@"User Deleted highscoreID %d", insertionHighScoreID);
                        }
                        
                        sqlite3_reset(statementUpdate);
                        sqlite3_finalize(statementUpdate);
                        
                    }
                }
                
            }
            
        }
        if (insertionHighScoreID != -1) {
            NSLog(@" -1 loop");
            //make database insertion query
            NSString *sqlInsert = [NSString stringWithFormat:@"INSERT INTO highscores (highscoreID, score, name, mode) VALUES (%d, %d, '%@', '%@')", insertionHighScoreID, score, name, mode];
            sqlite3_stmt * statementInsert;
            sqlite3_prepare_v2(database, [sqlInsert UTF8String], -1, &statementInsert, NULL);
            
            if(sqlite3_step(statementInsert) == SQLITE_DONE)
            {
                NSLog(@"User inserted at highscoreID %d", insertionHighScoreID);
            }
            sqlite3_reset(statementInsert);
            sqlite3_finalize(statementInsert);
        }
        NSLog(@"good");
        
        
    } else {
        NSLog(@"Highscore list doesn't contain scores");
        //make database insertion query
        NSString *sqlInsert = [NSString stringWithFormat:@"INSERT INTO highscores (highscoreID, score, name, mode) VALUES (%d, %d, '%@', '%@')", 0, score, name, mode];
        NSLog(@"%@", sqlInsert);
        
        sqlite3_stmt * statementInsert;
        sqlite3_prepare_v2(database, [sqlInsert UTF8String], -1, &statementInsert, NULL);
        
        if(sqlite3_step(statementInsert) == SQLITE_DONE)
        {
            NSLog(@"User inserted at highscoreID 0");
        }
        sqlite3_reset(statementInsert);
        sqlite3_finalize(statementInsert);
        
    }
    
    NSLog(@"Exiting");
    //sqlite3_reset(statement);
    //sqlite3_finalize(statement);
    
    sqlite3_close(database);
}


- (int)getMaxHighscoreID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int result = -1;
    
    //make database query
    NSString *sql = @"SELECT max(highscoreID) FROM highscores";
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    //get max highscoreID
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            result = sqlite3_column_int(statement, 0);
            
        }
    }
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return result;
}

- (void)clearHighscoresList {
    
    NSLog(@"%d", [self getMaxHighscoreID]);
    for (int i=0; i <= [self getMaxHighscoreID]; i++) {
        
        //database update
        sqlite3 *database;
        sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
        
        //sql
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM highscores WHERE highscoreID = %d", i];
        sqlite3_stmt * statement;
        sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
        //NSLog(@"%d", sqlite3_step(statement));
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"User Deleted highscoreID %d", i);
        }
        
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        
        sqlite3_close(database);
    }
    NSLog(@"All highscores deleted");
    
    
}


-(BOOL)highscoreListIsEmpty {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    int numRows = 0;
    
    //sql
    NSString *sql = @"SELECT highscoreID, score, name FROM highscores";
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    
    //counting
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            numRows++;
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    
    //check value of numRows
    if (numRows != 0) {
        return FALSE;
    } else {
        return TRUE;
    }
    
}

- (BOOL)verifyAsHighscore:(int)score {
    
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = @"SELECT highscoreID, score, name FROM highscores";
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    
    //counting
    if (sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            if (score >= sqlite3_column_int(statement, 1)) {
                sqlite3_reset(statement);
                sqlite3_finalize(statement);
                
                sqlite3_close(database);
                
                return TRUE;
            }
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return FALSE;
    
    
    
}

#pragma mark settings table methods
- (int)getSetting:(NSString *)settingName;
{
    int settingValue =-1;
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT settingName, settingValue FROM settings WHERE settingName = '%@'", settingName];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    //set return variable
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            settingValue = sqlite3_column_int(statement, 1);
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return settingValue;
    
}


- (void)setSetting:(NSString *)settingName toValue:(int)value
{
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"UPDATE settings SET settingValue = %d WHERE settingName = '%@'", value, settingName];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"User updated %@ to %d", settingName, value);
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
}


#pragma mark - productsTable methods


- (int)getAppProductIDWithiTunesProductID:(NSString *)iProductID {
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int appID=-1;
    
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT appID, productID FROM productIDMappings WHERE productID = '%@'", iProductID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            appID = sqlite3_column_int(statement, 0);
            
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return appID;
    
}


- (int)getCategoryIDWithiTunesProductID:(NSString *)iProductID {
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    //handle case where iProductID doesn't exist
    if (productID == -1) {
        return productID;
    }
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int categoryID = -1;
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT categoryID FROM productsTable WHERE productID = %d", productID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            categoryID = sqlite3_column_int(statement, 0);
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    
    sqlite3_close(database);
    
    
    return categoryID;
    
}


- (NSString *)getProductNameWithiTunesProductID:(NSString *)iProductID {
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    //handle case where iProductID doesn't exist
    if (productID == -1) {
        return @"-1";
    }
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSString *productName = @"-1";
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT productName FROM productsTable WHERE productID = %d", productID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            productName = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return productName;
}


- (NSString *)getProductTypeWithiTunesProductID:(NSString *)iProductID {
    
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    //handle case where iProductID doesn't exist
    if (productID == -1) {
        return @"-1";
    }
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSString *productType = @"-1";
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT type FROM productsTable WHERE productID = %d", productID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            productType = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return productType;

}


- (NSString *)getProductPriceWithiTunesProductID:(NSString *)iProductID {
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    //handle case where iProductID doesn't exist
    if (productID == -1) {
        return @"-1";
    }
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    NSString *productPrice = @"-1";
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT price FROM productsTable WHERE productID = %d", productID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            productPrice = [NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, 0)];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return productPrice;

    
}

- (int)getProductPurchaseMadeWithiTunesProductID:(NSString *)iProductID {
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    //handle case where iProductID doesn't exist
    if (productID == -1) {
        return productID;
    }
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    int purchaseMade = -1;
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"SELECT purchaseMade FROM productsTable WHERE productID = %d", productID];
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            purchaseMade = sqlite3_column_int(statement, 0);
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    
    return purchaseMade;

    
}

- (NSMutableArray *)getIProductIDs {
    NSMutableArray *productIDs = [[NSMutableArray alloc] init];
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql =@"SELECT productID FROM productIDMappings";
    sqlite3_stmt * statement;
    int sqlResult = sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if(sqlResult == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSString *productID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
            
            [productIDs addObject:productID];
        }
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
    return productIDs;
    
}

- (void)setProductPurchaseMadeWithiTunesProductID:(NSString *)iProductID toValue:(int)value {
    int productID = [self getAppProductIDWithiTunesProductID:iProductID];
    
    
    sqlite3 *database;
    sqlite3_open([[DBAccess getDBPath] UTF8String], &database);
    
    //sql
    NSString *sql = [NSString stringWithFormat:@"UPDATE productsTable SET purchaseMade = %d WHERE productID = %d", value, productID];
    sqlite3_stmt *statement;
    sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL);
    
    if (sqlite3_step(statement) == SQLITE_DONE) {
        NSLog(@"User updated %@ purchaseMade to %d", iProductID, value);
    }
    
    sqlite3_reset(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(database);
    
}



@end
