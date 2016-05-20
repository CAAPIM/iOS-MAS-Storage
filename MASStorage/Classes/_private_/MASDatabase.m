//
//  MASDatabase.m
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
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
    MASStorageErrorFindFromLocalStorage = 106
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

- (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    //
    // Attempt to open the database
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement
        //
        NSString *deleteSQL = @"DELETE FROM PROPERTIES";
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
                
                DLog(@"success in executing SQLite3 DELETE all");

                //
                // Notify
                //
                if (completion) completion(YES, nil);
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


- (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(key);
    
    //
    // Open DB
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement
        //
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM PROPERTIES WHERE KEY=\"%@\"", key];
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
                DLog(@"success in executing SQLite3 DELETE into PROPERTIES");
                
                //
                // Notify
                //
                if (completion) completion(YES, nil);
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

- (void)findObjectsFromLocalStorageUsingTag:(NSString *)tag
                                 completion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSParameterAssert(tag);
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    //
    //Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TAG FROM PROPERTIES WHERE TAG=\"%@\"", tag];
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) != SQLITE_DONE) {
                
                NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
                
                //
                //Adding KEY to Dictionary
                //
                [returnData setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"key"];

                //
                //Adding MESSAGE to Dictionary
                //
                const void *ptr = sqlite3_column_blob(statement, 1);
                int size = sqlite3_column_bytes(statement, 1);
                NSData* objData = [[NSData alloc] initWithBytes:ptr length:size];
                NSObject *object = [NSKeyedUnarchiver unarchiveObjectWithData:objData];
                [returnData setObject:object forKey:@"value"];
                
                //
                //Adding TAG to Dictionary
                //
                NSString *tag = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [returnData setObject:tag forKey:@"tag"];

                //
                //Adding MODIFIED_DATE to Dictionary
                //
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow: sqlite3_column_double(statement, 3)];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE MMM d hh:mm:ss z yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:date];
                [returnData setObject:dateString forKey:@"modifiedDate"];
                
                //
                //Adding Data to ReturnArray
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
            withErrorCode:MASStorageErrorFindFromLocalStorage]);
        
        return;
    }
    
    //
    // Notify of error
    //
    if (completion) completion(nil, [self errorOpeningDatabase]);
}


# pragma mark - Get

- (void)getObjectFromLocalStorageUsingKey:(NSString *)key
                               completion:(void (^)(NSDictionary *response, NSError *error))completion
{
    NSParameterAssert(key);
    
    //
    //Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = [NSString stringWithFormat:@"SELECT KEY, VALUE, TYPE, MODIFIED_DATE FROM PROPERTIES WHERE KEY=\"%@\"", key];
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;

        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
                
                //
                //Adding KEY to Dictionary
                //
                [returnData setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"key"];
                
                
                //
                //Adding VALUE to Dictionary
                //
                const void *ptr = sqlite3_column_blob(statement, 1);
                int size = sqlite3_column_bytes(statement, 1);
                
                NSData* objData = [[NSData alloc] initWithBytes:ptr length:size];
                [returnData setObject:objData forKey:@"value"];

                
                //
                //Adding TYPE to Dictionary
                //
                NSString *type = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [returnData setObject:type forKey:@"type"];
                
                //
                //Adding MODIFIED_DATE to Dictionary
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
                //Create Error Message
                //
                NSString *message = NSLocalizedString(@"Failed to GET object from local storage. Error #: ", Nil);
                message = [NSString stringWithFormat:@"%@%s",message,sqlite3_errmsg(database)];
                NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                              code:MASStorageErrorLoadFromLocalStorage
                                                          userInfo:@{NSLocalizedDescriptionKey:message}];
                
                //
                //Block callback
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


- (void)getObjectsFromLocalStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    //
    //Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = @"SELECT KEY, VALUE, TYPE, MODIFIED_DATE FROM PROPERTIES";
        const char *query_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) != SQLITE_DONE) {
                
                NSMutableDictionary *returnData = [[NSMutableDictionary alloc] init];
                
                //
                //Adding KEY to Dictionary
                //
                [returnData setObject:[[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)] forKey:@"key"];
                
                //
                //Adding VALUE to Dictionary
                //
                const void *ptr = sqlite3_column_blob(statement, 1);
                int size = sqlite3_column_bytes(statement, 1);
                
                NSData* objData = [[NSData alloc] initWithBytes:ptr length:size];
                [returnData setObject:objData forKey:@"value"];
                
                //
                //Adding TYPE to Dictionary
                //
                NSString *type = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2)];
                [returnData setObject:type forKey:@"type"];

                //
                //Adding MODIFIED_DATE to Dictionary
                //
                NSDate *date = [NSDate dateWithTimeIntervalSince1970: sqlite3_column_double(statement, 3)];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"EEE MMM d hh:mm:ss z yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:date];
                [returnData setObject:dateString forKey:@"modifiedDate"];

                
                //
                //Adding Data to ReturnArray
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
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);

    //
    //Open DB
    //
    if ([self openDB])
    {
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = @"INSERT INTO PROPERTIES (KEY, VALUE, TYPE, MODIFIED_DATE) VALUES (?, ?, ?, ?)";
        const char *save_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the data to bind.
        //
        NSData *objData = (NSData *)object;
        

        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, save_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            // Bind the parameters (note that these use a 1-based index, not 0).
            sqlite3_bind_text(statement, 1, [key UTF8String], (int)[key length], SQLITE_STATIC);
            sqlite3_bind_blob(statement, 2, [objData bytes], (int)[objData length], SQLITE_STATIC);
            sqlite3_bind_text(statement, 3, [type UTF8String], (int)[type length], SQLITE_STATIC);
            sqlite3_bind_double(statement,4, [[NSDate date] timeIntervalSince1970]);
        
            //
            // Execute the statement.
            //
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
                DLog(@"success in executing SQLite3 INSERT");

                //
                //Notification callback
                //
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:MASStorageOperationDidSaveToLocalStorageNotification object:Nil];

                //
                //Block callback
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
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);
    
    //
    //Open DB
    //
    if ([self openDB]) {
        
        //
        // Construct the query and empty prepared statement.
        //
        NSString *querySQL = @"REPLACE INTO PROPERTIES (KEY, VALUE, TYPE, MODIFIED_DATE) VALUES (?, ?, ?, ?)";
        const char *update_stmt = [querySQL UTF8String];
        sqlite3_stmt *statement;
        
        
        //
        // Prepare the data to bind.
        //
        NSData *objData = (NSData *)object;
        
        
        //
        // Prepare the statement.
        //
        if (sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL) == SQLITE_OK) {
            
            // Bind the parameters (note that these use a 1-based index, not 0).
            sqlite3_bind_text(statement, 1, [key UTF8String], (int)[key length], SQLITE_STATIC);
            sqlite3_bind_blob(statement, 2, [objData bytes], (int)[objData length], SQLITE_STATIC);
            sqlite3_bind_text(statement, 3, [type UTF8String], (int)[type length], SQLITE_STATIC);
            sqlite3_bind_double(statement,4, [[NSDate date] timeIntervalSince1970]);
            
            //
            // Execute the statement.
            //
            if (sqlite3_step(statement) == SQLITE_DONE) {
                
                DLog(@"success in executing SQLite3 REPLACE");
                
                //
                //Notification callback
                //
                NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                [notificationCenter postNotificationName:MASStorageOperationDidSaveToLocalStorageNotification object:Nil];
                
                //
                //Block callback
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
    //Get LocalStorage path
    NSString *databasePath = [MASDatabase pathToLocalStorage];
    DLog(@"SQLite db path: %@",databasePath);
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath:databasePath ] == NO) {
        
        if ([self openDB]) {
            
            char *errMsg;
            //KEY VARCHAR PRIMARY KEY NOT NULL UNIQUE
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS PROPERTIES (KEY VARCHAR PRIMARY KEY NOT NULL UNIQUE, VALUE BLOB, TYPE VARCHAR, MODIFIED_DATE DOUBLE);";
            
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

@end
