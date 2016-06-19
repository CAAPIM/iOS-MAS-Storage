//
//  MASDatabase.h
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#pragma mark - Storage Notifications

static NSString * const MASStorageOperationDidSaveToLocalStorageNotification = @"com.ca.storage.operation.save";


@interface MASDatabase : NSObject


# pragma mark - Lifecycle

/**
 *  Singleton instance of MASDatabase. 
 *
 *  It creates the SQLite database in case it doesn't exist.
 *
 *  @return Singleton instance of MASDatabase.
 */
+ (instancetype)sharedDatabase;


# pragma mark - Delete

/**
 *  Delete ALL objects from local storage.
 *
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
//- (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)deleteAllObjectsUsingMode:(MASStorageMode)mode
                       completion:(void (^)(BOOL success, NSError *error))completion;



/**
 *  Delete an object from local storage based on a given key.
 *
 *  @param key        The Key used to delete the object from local storage.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
- (void)deleteObjectUsingKey:(NSString *)key
                        mode:(MASStorageMode)mode
                  completion:(void (^)(BOOL success, NSError *error))completion;
//- (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
//                                  completion:(void (^)(BOOL success, NSError *error))completion;



# pragma mark - Find


/**
 *  Get an object from local storage based in a giving key.
 *
 *  @param key        The Key used to get the object from local storage.
 *  @param completion A (NSDictionary *response, NSError *error) completion block.
 */
- (void)findObjectUsingKey:(NSString *)key
                      mode:(MASStorageMode)mode
                completion:(void (^)(NSDictionary *response, NSError *error))completion;



/**
 *  Get all objects from Local Storage.
 *
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
- (void)findObjectsUsingMode:(MASStorageMode)mode
                  completion:(void (^)(NSArray *objects, NSError *error))completion;



# pragma mark - Save

/**
 *  Save an object into local storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param mode       The MASStorageMode to be used in the search.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
- (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                            mode:(MASStorageMode)mode
                      completion:(void (^)(BOOL success, NSError *error))completion;



# pragma mark - Update


/**
 *  Update an object into local storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param mode       The MASStorageMode to be used in the search.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
- (void)updateToLocalStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                              mode:(MASStorageMode)mode
                        completion:(void (^)(BOOL success, NSError *error))completion;


@end
