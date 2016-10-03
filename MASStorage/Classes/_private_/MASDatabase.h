//
//  MASDatabase.h
//  MASStorage
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#pragma mark - Storage Notifications

static NSString * _Nonnull const MASStorageOperationDidSaveToLocalStorageNotification = @"com.ca.storage.operation.save";


@interface MASDatabase : NSObject


# pragma mark - Lifecycle

/**
 *  Singleton instance of MASDatabase. 
 *
 *  It creates the SQLite database in case it doesn't exist.
 *
 *  @return Singleton instance of MASDatabase.
 */
+ (nonnull instancetype)sharedDatabase;


# pragma mark - Delete

/**
 *  Delete ALL objects from local storage.
 *
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
//- (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion;
- (void)deleteAllObjectsUsingMode:(MASLocalStorageSegment)mode
                       completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;



/**
 *  Delete an object from local storage based on a given key.
 *
 *  @param key        The Key used to delete the object from local storage.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
- (void)deleteObjectUsingKey:(nonnull NSString *)key
                        mode:(MASLocalStorageSegment)mode
                  completion:(nullable void (^)(BOOL success, NSError * _Nonnull error))completion;
//- (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
//                                  completion:(void (^)(BOOL success, NSError *error))completion;



# pragma mark - Find


/**
 *  Get an object from local storage based in a giving key.
 *
 *  @param key        The Key used to get the object from local storage.
 *  @param completion A (NSDictionary *response, NSError *error) completion block.
 */
- (void)findObjectUsingKey:(nonnull NSString *)key
                      mode:(MASLocalStorageSegment)mode
                completion:(nullable void (^)(NSDictionary * _Nullable response, NSError * _Nullable error))completion;



/**
 *  Get all objects from Local Storage.
 *
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
- (void)findObjectsUsingMode:(MASLocalStorageSegment)mode
                  completion:(nullable void (^)(NSArray * _Nullable objects, NSError * _Nullable error))completion;



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
- (void)saveToLocalStorageObject:(nonnull NSObject *)object
                         withKey:(nonnull NSString *)key
                         andType:(nonnull NSString *)type
                            mode:(MASLocalStorageSegment)mode
                      completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;



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
- (void)updateToLocalStorageObject:(nonnull NSObject *)object
                           withKey:(nonnull NSString *)key
                           andType:(nonnull NSString *)type
                              mode:(MASLocalStorageSegment)mode
                        completion:(nullable void (^)(BOOL success, NSError * _Nullable error))completion;


@end
