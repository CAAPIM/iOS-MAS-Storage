//
//  MASCloudStorage.h
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <Foundation/Foundation.h>

#import <MASFoundation/MASFoundation.h>


/**
 *  This class exposes Cloud Storage features
 */
@interface MASCloudStorage : NSObject


# pragma mark - Delete

/**
 *  Delete an Object from Cloud Storage based on a given key.
 *
 *  @param key        The Key used to delete the object from cloud storage.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)deleteObjectFromCloudStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion;


# pragma mark - Get

/**
 *  Get an object from Cloud Storage based on a specific key.
 *
 *  @param key        The Key used to get the object from cloud storage.
 *  @param completion A (MASObject *object, NSError *error) completion block.
 */
+ (void)getObjectFromCloudStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion;



/**
 *  Get all objects from Cloud Storage.
 *
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
+ (void)getObjectsFromCloudStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion;


# pragma mark - Save

/**
 *  Save an object into Cloud Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)saveToCloudStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                      completion:(void (^)(BOOL success, NSError *error))completion;


# pragma mark - Update

/**
 *  Update an object into Cloud Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)updateToCloudStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                        completion:(void (^)(BOOL success, NSError *error))completion;

@end
