//
//  MASDatabase.m
//  MASStorage
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASDatabase.h"

#import <sqlite3.h>

#define kSDKErrorDomain     @"com.ca.MASStorage:ErrorDomain"
#define kDatabaseName       @"_MAS_Database_"


typedef NS_ENUM (NSUInteger, MASStorageError)
{
    MASStorageErrorSaveToLocalStorage = 101,
    MASStorageErrorLoadFromLocalStorage = 102,
    MASStorageErrorOpenLocalStorage = 103,
    MASStorageErrorDeleteLocalStorage = 104,
    MASStorageErrorDeleteAllLocalStorage = 105,
    MASStorageErrorFindFromLocalStorage = 106,
    MASStorageErrorUserSessionIsCurrentlyLocked = 108,
};


@implementation MASDatabase

static sqlite3 *database;
static MASDatabase *_sharedDatabase = nil;


# pragma mark - Lifecycle

+ (instancetype)sharedDatabase
{
    static dispatch_once_t onceToken;
    
    if (!_sharedDatabase) {
        
        dispatch_once(&onceToken, ^{
            
            _sharedDatabase = [[MASDatabase alloc] init];
        });
    }
    
    return _sharedDatabase;
}


- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        [self createDatabase];
        [self openDB];
    }
    
    return self;
}


# pragma mark - Delete

- (void)deleteAllObjectsUsingMode:(MASLocalStorageSegment)mode
                       completion:(void (^)(BOOL success, NSError *error))completion
{
    //
    // Attempt to open the database
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement
        //
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM PROPERTIES WHERE MODE=%ld", (long)mode];
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_stmt *statement;
        
        //
        // Prepare the statement
        //
        if (sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //
            // Execute the statement
            //
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
                if (sqlite3_changes(database)) {
                    
                    DLog(@"success in executing SQLite3 DELETE all");
                    
                    //
                    // Notify
                    //
                    if (completion) completion(YES, nil);
                    
                }
                else {
                    
                    DLog(@"could not find value for mode %ld", (long)mode);
                    
                    //
                    // Create Error Message
                    //
                    NSString *message = NSLocalizedString(@"Object(s) not found.", Nil);
                    NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                                  code:MASStorageErrorDeleteAllLocalStorage
                                                              userInfo:@{NSLocalizedDescriptionKey:message}];
                    
                    //
                    // Block callback
                    //
                    if (completion) {
                        
                        completion(NO,localizedError);
                    }
                }
            }
            
            //
            // Else failed to execute the statement
            //
            else if (completion) completion(NO, [self errorExecutingStatement:deleteSQL
                withErrorCode:MASStorageErrorDeleteAllLocalStorage]);
    
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(NO, [self errorPreparingStatement:deleteSQL
            withErrorCode:MASStorageErrorDeleteAllLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(NO, [self errorOpeningDatabase]);
}


- (void)deleteObjectUsingKey:(NSString *)key
                        mode:(MASLocalStorageSegment)mode
                  completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(key);
    
    if (mode != MASLocalStorageSegmentApplication && ![MASUser currentUser].objectId) {
        
        NSString *message = NSLocalizedString(@"Unauthenticated user", @"unauthenticated user");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorFindFromLocalStorage
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(NO,localizedError);
        
        return;
    }
    else if (mode != MASLocalStorageSegmentApplication && [MASUser currentUser].isSessionLocked)
    {
        NSString *message = NSLocalizedString(@"User session is currently locked", @"User session is currently locked");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorUserSessionIsCurrentlyLocked
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }

    //
    // Open DB
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement
        //
        NSString *deleteSQL;
        NSString *currentUserId = [MASUser currentUser].objectId;
        
        switch (mode) {
                
            case MASLocalStorageSegmentApplication:
                
                deleteSQL = [NSString stringWithFormat:@"DELETE FROM PROPERTIES WHERE KEY=\"%@\" AND MODE=%ld", key, (long)mode];
                break;
                
            default:
                
                deleteSQL = [NSString stringWithFormat:@"DELETE FROM PROPERTIES WHERE KEY=\"%@\" AND MODE=%ld AND CREATED_BY=\"%@\"", key, (long)mode, currentUserId];
                break;
        }
        
        const char *delete_stmt = [deleteSQL UTF8String];
        sqlite3_stmt *statement;

        //
        // Prepare the statement
        //
        if (sqlite3_prepare_v2(database, delete_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //
            // Execute the statement
            //
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                if (sqlite3_changes(database)) {
                    
                    DLog(@"success in executing SQLite3 DELETE into PROPERTIES");
                    
                    //
                    // Notify
                    //
                    if (completion) completion(YES, nil);

                }
                else {
                    
                    DLog(@"could not find value for key %@", key);
                    
                    //
                    // Create Error Message
                    //
                    NSString *message = NSLocalizedString(@"Object not found.", Nil);
                    NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                                  code:MASStorageErrorDeleteLocalStorage
                                                              userInfo:@{NSLocalizedDescriptionKey:message}];
                    
                    //
                    // Block callback
                    //
                    if (completion) {
                        
                        completion(NO,localizedError);
                    }
                }
            }
            
            //
            // Else failed to execute the statement
            //
            else if (completion) completion(NO, [self errorExecutingStatement:deleteSQL
                withErrorCode:MASStorageErrorDeleteLocalStorage]);
            
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(NO, [self errorPreparingStatement:deleteSQL
            withErrorCode:MASStorageErrorDeleteLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(NO, [self errorOpeningDatabase]);
}


# pragma mark - Find

- (void)findObjectUsingKey:(NSString *)key
                      mode:(MASLocalStorageSegment)mode
                completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSParameterAssert(key);
    
    if (mode != MASLocalStorageSegmentApplication && ![MASUser currentUser].objectId) {
        
        NSString *message = NSLocalizedString(@"Unauthenticated user", @"unauthenticated user");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorFindFromLocalStorage
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }
    else if (mode != MASLocalStorageSegmentApplication && [MASUser currentUser].isSessionLocked)
    {
        NSString *message = NSLocalizedString(@"User session is currently locked", @"User session is currently locked");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorUserSessionIsCurrentlyLocked
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }

    //
    // Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL;
        NSString *currentUserId = [MASUser currentUser].objectId;
        
        switch (mode) {
                
            case MASLocalStorageSegmentApplication:
                
                querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TYPE, MODIFIED_DATE, CREATED_DATE, CREATED_BY, MODE FROM PROPERTIES WHERE MODE=%ld AND KEY=\"%@\"", (long)mode,key];
                break;
                
            default:
                
                querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TYPE, MODIFIED_DATE, CREATED_DATE, CREATED_BY, MODE FROM PROPERTIES WHERE MODE=%ld AND CREATED_BY=\"%@\" AND KEY=\"%@\"", (long)mode,currentUserId, key];
                break;
        }

        const char *query_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
                
                //
                // Adding KEY to Dictionary
                //
                [returnData setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"key"];
                
                
                //
                // Adding VALUE to Dictionary
                //
                const void *ptr = sqlite3_column_blob(statement, 1);
                int size = sqlite3_column_bytes(statement, 1);
                
                NSData* objData = [[NSData alloc] initWithBytes:ptr length:size];
                [returnData setObject:objData forKey:@"value"];
                
                
                //
                // Adding TYPE to Dictionary
                //
                NSString *type = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [returnData setObject:type forKey:@"type"];
                
                //
                // Adding MODIFIED_DATE to Dictionary
                //
                NSDate *date = [NSDate dateWithTimeIntervalSince1970: sqlite3_column_double(statement, 3)];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE MMM d hh:mm:ss z yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:date];
                [returnData setObject:dateString forKey:@"modifiedDate"];
                
                if (completion) {
                    
                    completion(returnData, nil);
                }
            }
            else {
                
                DLog(@"could not find value for key %@", key);
                
                //
                // Create Error Message
                //
                NSString *message = NSLocalizedString(@"Failed to GET object from local storage. Error #: ", Nil);
                message = [NSString stringWithFormat:@"%@%s",message,sqlite3_errmsg(database)];
                NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                              code:MASStorageErrorLoadFromLocalStorage
                                                          userInfo:@{NSLocalizedDescriptionKey:message}];
                
                //
                // Block callback
                //
                if (completion) {
                    
                    completion(nil,localizedError);
                }
            }
            
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(nil, [self errorPreparingStatement:querySQL
                                                        withErrorCode:MASStorageErrorLoadFromLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(nil, [self errorOpeningDatabase]);
    
}

- (void)findObjectsUsingMode:(MASLocalStorageSegment)mode
                  completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    if (mode != MASLocalStorageSegmentApplication && ![MASUser currentUser].objectId) {

        NSString *message = NSLocalizedString(@"Unauthenticated user", @"unauthenticated user");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorFindFromLocalStorage
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }
    else if (mode != MASLocalStorageSegmentApplication && [MASUser currentUser].isSessionLocked)
    {
        NSString *message = NSLocalizedString(@"User session is currently locked", @"User session is currently locked");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorUserSessionIsCurrentlyLocked
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }
    
    //
    // Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL;
        NSString *currentUserId = [MASUser currentUser].objectId;
        
        switch (mode) {
                
            case MASLocalStorageSegmentApplication:
                
                querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TYPE, MODIFIED_DATE, CREATED_DATE, CREATED_BY, MODE FROM PROPERTIES WHERE MODE=%ld", (long)mode];
                break;
                
            default:
                
                querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TYPE, MODIFIED_DATE, CREATED_DATE, CREATED_BY, MODE FROM PROPERTIES WHERE MODE=%ld AND CREATED_BY=\"%@\"", (long)mode,currentUserId];
                break;
        }
        
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) != SQLITE_DONE) {
                
                NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
                
                //
                // Adding KEY to Dictionary
                //
                [returnData setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"key"];
                
                //
                // Adding VALUE to Dictionary
                //
                const void *ptr = sqlite3_column_blob(statement, 1);
                int size = sqlite3_column_bytes(statement, 1);
                
                NSData* objData = [[NSData alloc] initWithBytes:ptr length:size];
                [returnData setObject:objData forKey:@"value"];
                
                //
                // Adding TYPE to Dictionary
                //
                NSString *type = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [returnData setObject:type forKey:@"type"];
                
                //
                // Adding MODIFIED_DATE to Dictionary
                //
                NSDate *date = [NSDate dateWithTimeIntervalSince1970: sqlite3_column_double(statement, 3)];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE MMM d hh:mm:ss z yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:date];
                [returnData setObject:dateString forKey:@"modifiedDate"];
                
                
                //
                // Adding Data to ReturnArray
                //
                [returnArray addObject:returnData];
            }
            
            if (completion) {
                
                completion(returnArray, nil);
            }
            
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(nil, [self errorPreparingStatement:querySQL
                                                        withErrorCode:MASStorageErrorLoadFromLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(nil, [self errorOpeningDatabase]);
}


# pragma mark - Save

- (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                            mode:(MASLocalStorageSegment)mode
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);

    if (mode != MASLocalStorageSegmentApplication && ![MASUser currentUser].objectId) {
        
        NSString *message = NSLocalizedString(@"Unauthenticated user", @"unauthenticated user");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorFindFromLocalStorage
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(NO,localizedError);
        
        return;
    }
    else if (mode != MASLocalStorageSegmentApplication && [MASUser currentUser].isSessionLocked)
    {
        NSString *message = NSLocalizedString(@"User session is currently locked", @"User session is currently locked");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorUserSessionIsCurrentlyLocked
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }

    //
    // Open DB
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = @"INSERT INTO PROPERTIES (KEY, VALUE, TYPE, MODIFIED_DATE, CREATED_DATE, CREATED_BY, MODE) VALUES (?, ?, ?, ?, ?, ?, ?)";
        const char *save_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the data to bind.
        //
        NSData *objData = (NSData *)object;
        NSString *created_by_stmt = [MASUser currentUser].objectId;
        
        if (mode == MASLocalStorageSegmentApplication) {
            
            created_by_stmt = [MASApplication currentApplication].identifier;
        }


        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, save_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            // Bind the parameters (note that these use a 1-based index, not 0).
            sqlite3_bind_text(statement, 1, [key UTF8String], (int)[key length], SQLITE_STATIC);
            sqlite3_bind_blob(statement, 2, [objData bytes], (int)[objData length], SQLITE_STATIC);
            sqlite3_bind_text(statement, 3, [type UTF8String], (int)[type length], SQLITE_STATIC);
            sqlite3_bind_double(statement,4, [[NSDate date] timeIntervalSince1970]);
            sqlite3_bind_double(statement,5, [[NSDate date] timeIntervalSince1970]);
            sqlite3_bind_text(statement,6, [created_by_stmt UTF8String], (int)[created_by_stmt length], SQLITE_STATIC);
            sqlite3_bind_int(statement, 7, mode);
            
            //
            // Execute the statement.
            //
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
                DLog(@"success in executing SQLite3 INSERT");

                //
                // Notification callback
                //
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:MASStorageOperationDidSaveToLocalStorageNotification object:Nil];

                //
                // Block callback
                //
                if (completion) {
                    
                    completion(YES,nil);
                }
            }
            
            //
            // Else failed to execute the statement
            //
            else if (completion) completion(NO, [self errorExecutingStatement:querySQL
                withErrorCode:MASStorageErrorSaveToLocalStorage]);
            
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(NO, [self errorPreparingStatement:querySQL
            withErrorCode:MASStorageErrorSaveToLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(NO, [self errorOpeningDatabase]);
}


# pragma mark - Update

- (void)updateToLocalStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                              mode:(MASLocalStorageSegment)mode
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);
    
    if (mode != MASLocalStorageSegmentApplication && ![MASUser currentUser].objectId) {
        
        NSString *message = NSLocalizedString(@"Unauthenticated user", @"unauthenticated user");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorFindFromLocalStorage
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(NO,localizedError);
        
        return;
    }
    else if (mode != MASLocalStorageSegmentApplication && [MASUser currentUser].isSessionLocked)
    {
        NSString *message = NSLocalizedString(@"User session is currently locked", @"User session is currently locked");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorUserSessionIsCurrentlyLocked
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        if (completion) completion(nil,localizedError);
        
        return;
    }

    //
    // Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL;
        NSString *currentUserId = [MASUser currentUser].objectId;
        
        if (mode == MASLocalStorageSegmentApplication) {
            
            currentUserId = [MASApplication currentApplication].identifier;
        }
        
        
        switch (mode) {
                
            case MASLocalStorageSegmentApplication:
                
                querySQL = [NSString stringWithFormat:@"UPDATE PROPERTIES SET VALUE = ?, TYPE = ?, MODIFIED_DATE = ? WHERE KEY=\"%@\" AND MODE=%ld", key, (long)mode];
                break;
                
            default:
                
                querySQL = [NSString stringWithFormat:@"UPDATE PROPERTIES SET VALUE = ?, TYPE = ?, MODIFIED_DATE = ? WHERE KEY=\"%@\" AND MODE=%ld AND CREATED_BY=\"%@\"", key, (long)mode, currentUserId];
                break;
        }
        
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the data to bind.
        //
        NSData *objData = (NSData *)object;
        
//        NSString *created_by_stmt = [MASUser currentUser].objectId;
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL) == SQLITE_OK) {

            //
            // Update Columns
            //
            sqlite3_bind_blob(statement, 1, [objData bytes], (int)[objData length], SQLITE_STATIC);
            sqlite3_bind_text(statement, 2, [type UTF8String], (int)[type length], SQLITE_STATIC);
            sqlite3_bind_double(statement,3, [[NSDate date] timeIntervalSince1970]);
//            sqlite3_bind_text(statement, 4, [key UTF8String], (int)[key length], SQLITE_STATIC);
//            sqlite3_bind_int(statement, 5, mode);
//            sqlite3_bind_text(statement,6, [created_by_stmt UTF8String], (int)[created_by_stmt length], SQLITE_STATIC);
            
            
            //
            // Execute the statement.
            //
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
                DLog(@"success in executing SQLite3 UPDATE");
                
                //
                //Notification callback
                //
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:MASStorageOperationDidSaveToLocalStorageNotification object:Nil];
                
                //
                // Block callback
                //
                if (completion) {
                    
                    completion(YES,nil);
                }
            }
            
            //
            // Else failed to execute the statement
            //
            else if (completion) completion(NO, [self errorExecutingStatement:querySQL
                withErrorCode:MASStorageErrorSaveToLocalStorage]);
            
            //
            // Finalize
            //
            sqlite3_finalize(statement);
            
            return;
        }
        
        //
        // Notify of error
        //
        if (completion) completion(NO, [self errorPreparingStatement:querySQL
            withErrorCode:MASStorageErrorSaveToLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(NO, [self errorOpeningDatabase]);
}


#pragma mark - Private

- (void)createDatabase
{
    //
    // Get LocalStorage path
    //
    NSString *databasePath = [MASDatabase pathToLocalStorage];
    DLog(@"SQLite db path: %@",databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath ] == NO) {
        
        if ([self openDB]) {
            
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PROPERTIES (KEY VARCHAR NOT NULL, VALUE BLOB, TYPE VARCHAR, MODIFIED_DATE DOUBLE NOT NULL, CREATED_DATE DOUBLE, CREATED_BY VARCHAR, MODE INTEGER NOT NULL, PRIMARY KEY (KEY, MODE, CREATED_BY));";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
                
                DLog(@"SQLite3_exec problem");
            }
            else {
            
                DLog(@"Success in executing SQLite3 CREATE TABLE");
            }
            
            return;
        }
        
        DLog(@"ERROR in SQLite3 - COULD NOT OPEN DB");
    }
    else {
        
        if ([self openDB]) {
            
            int currentVersion = [self getDatabaseUserVersion:database];
            
            //Verify the User Version
            if (currentVersion != Database_User_Version) {
                
                //Update Database Schema with New Tables and/or Columns
                [self alterDatabase];
                
                //Update Database User Version
                [self setDatabaseUserVersion:Database_User_Version];
            }
        }

    }
}


- (void)alterDatabase
{
    char *errMsg;
    const char *sql_stmt;
    
    sql_stmt = "ALTER TABLE PROPERTIES ADD COLUMN CREATED_DATE DOUBLE;";
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        
        DLog(@"SQLite3_exec problem");
        
        return;
    }
    else {
        
        DLog(@"Success in executing SQLite3 ALTER TABLE");
    }

    sql_stmt = "ALTER TABLE PROPERTIES ADD COLUMN CREATED_BY VARCHAR;";
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        
        DLog(@"SQLite3_exec problem");
        
        return;
    }
    else {
        
        DLog(@"Success in executing SQLite3 ALTER TABLE");
    }
    
    sql_stmt = "ALTER TABLE PROPERTIES ADD COLUMN MODE INTEGER NOT NULL DEFAULT '1';";
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        
        DLog(@"SQLite3_exec problem");
        
        return;
    }
    else {
        
        DLog(@"Success in executing SQLite3 ALTER TABLE");
    }
}


- (NSError *)errorExecutingStatement:(NSString *)statement withErrorCode:(MASStorageError)errorCode
{
    //
    // Error message
    //
    NSString *message = NSLocalizedString(@"Failed to execute the sql statement", nil);
    message = [NSString stringWithFormat:@"%@ \'%@\'", message, statement];
    message = [NSString stringWithFormat:@"%@.  sqlite3 error #: %s", message, sqlite3_errmsg(database)];
    
    //
    // Create NSError
    //
    NSError *error = [NSError errorWithDomain:kSDKErrorDomain
        code:errorCode
        userInfo:@
        {
            NSLocalizedDescriptionKey : message
        }];

    return error;
}


- (NSError *)errorOpeningDatabase
{
    //
    // Create NSError
    //
    NSError *error = [NSError errorWithDomain:kSDKErrorDomain
        code:MASStorageErrorOpenLocalStorage
        userInfo:@
        {
            NSLocalizedDescriptionKey : NSLocalizedString(@"Failed to OPEN local storage database.", nil)
        }];
    
    return error;
}


- (NSError *)errorPreparingStatement:(NSString *)statement withErrorCode:(MASStorageError)errorCode
{
    //
    // Error message
    //
    NSString *message = NSLocalizedString(@"Failed to prepare the sql statement", nil);
    message = [NSString stringWithFormat:@"%@ \'%@\'", message, statement];
    message = [NSString stringWithFormat:@"%@.  sqlite3 error #: %s", message, sqlite3_errmsg(database)];
    
    //
    // Create NSError
    //
    NSError *error = [NSError errorWithDomain:kSDKErrorDomain
        code:errorCode
        userInfo:@
        {
            NSLocalizedDescriptionKey : message
        }];
    
    return error;
}


- (BOOL)openDB
{
    BOOL isDBOpened;
    
    if (database == NULL) {
        
        sqlite3 *newDBconnection;
        
        //
        //Get LocalStorage path
        //
        NSString *databasePath = [MASDatabase pathToLocalStorage];
        const char *dbpath = [databasePath UTF8String];

        //
        //Open the DB using iOS File Protection
        //
        if (sqlite3_open_v2(dbpath, &newDBconnection, SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE|SQLITE_OPEN_FILEPROTECTION_COMPLETEUNLESSOPEN, NULL) == SQLITE_OK) {

            database = newDBconnection;
            
            isDBOpened = YES;
        }
        else {
            
            DLog(@"Error in opening database :(");
            database = NULL;
            
            isDBOpened = NO;
        }
    }
    else {
        
        isDBOpened = YES;
    }
    
    return isDBOpened;
}


+ (NSString *)pathToLocalStorage
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",kDatabaseName]];
    
    return path;
}


/**
 *  Counts the number of column
 *
 *  @param tableName Database Table name
 *
 *  @return Number of column
 */
- (NSInteger)tableColumnCount:(NSString *)tableName
{
    NSString *query = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    const char *query2 = [query UTF8String];
    NSInteger nFields =0;
    sqlite3_stmt *statement;
    
    if(sqlite3_prepare_v2(database, query2, -1, &statement, NULL) == SQLITE_OK) {
        
        while(sqlite3_step(statement) == SQLITE_ROW) {
            
            nFields++;
            
            sprintf("Column Name", "%s", sqlite3_column_text(statement, 1));
            //do something with colName because it contains the column's name
            
            //returns the name
            NSLog(@"Column name: %s",sqlite3_column_text(statement, 1));
            
            //returns the type
            NSLog(@"Column name: %s",sqlite3_column_text(statement, 2));
        }
    }
    
    sqlite3_finalize(statement);
    
    return nFields;
}


/**
 *  Return the Database User Version
 *
 *  @param db SQlite DB
 *
 *  @return User Version of the Database
 */
- (int)getDatabaseUserVersion:(sqlite3*)db
{
    static sqlite3_stmt *stmt_version;
    int databaseVersion;
    
    if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &stmt_version, NULL) == SQLITE_OK) {
        
        while(sqlite3_step(stmt_version) == SQLITE_ROW) {
            
            databaseVersion = sqlite3_column_int(stmt_version, 0);
        }
        
        DLog(@"%s: the Database Version is: %d", __FUNCTION__, databaseVersion);
    }
    else {
    
        NSLog(@"%s: ERROR Preparing: , %s", __FUNCTION__, sqlite3_errmsg(db) );
    }
    
    sqlite3_finalize(stmt_version);
    
    return databaseVersion;
}

- (BOOL)setDatabaseUserVersion:(int)version
{
    //Update Database User Version
    char *errMsg;
    NSString *querySQL = [NSString stringWithFormat:@"PRAGMA user_version = %d",version];
    const char *sql_stmt = [querySQL UTF8String];
    
    if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK) {
        
        DLog(@"SQLite3_exec problem");
        
        return NO;
    }
    else {
        
        DLog(@"Success in executing SQLite3 UPDATING DATABASE USER VERSION");
    }
    
    return YES;

}


@end
