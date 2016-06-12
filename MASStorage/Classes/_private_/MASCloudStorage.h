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
#import "MASStorageConstants.h"

/**
 *  This class exposes Cloud Storage features
 */
@interface MASCloudStorage : NSObject


# pragma mark - Find methods

/**
 *  Find an object from Cloud Storage based on a specific key
 *
 *  @param key        The Key used to get the object from cloud storage
 *  @param mode       The MASStorageMode to be used in the search
 *  @param completion A (MASObject *object, NSError *error) completion block
 */
+ (void)findObjectUsingKey:(NSString *)key
                      mode:(MASStorageMode)mode
                completion:(void (^)(MASObject *object, NSError *error))completion;



/**
 *  Find objects from Cloud Storage based on the MASStorageMode
 *
 *  @param mode       The MASStorageMode to be used in the search
 *  @param completion A (NSArray *objects, NSError *error) completion block
 */
+ (void)findObjectsUsingMode:(MASStorageMode)mode
                  completion:(void (^)(NSArray *objects, NSError *error))completion;



# pragma mark - Save/Update method

/**
 *  Save/Update an object into Cloud Storage
 *
 *  @param object     Object to be saved/updated. It must conform to NSObject
 *  @param key        Key to be used when saving the object
 *  @param type       Type of the object been saved
 *  @param mode       The MASStorageMode to be used in the save
 *  @param completion The standard (BOOL success, NSError *error) completion block
 */
+ (void)saveObject:(NSObject *)object
           withKey:(NSString *)key
              type:(NSString *)type
              mode:(MASStorageMode)mode
        completion:(void (^)(BOOL success, NSError *error))completion;



# pragma mark - Delete method

/**
 *  Delete an Object from Cloud Storage based on a given key.
 *
 *  @param key        The Key used to delete the object from cloud storage
 *  @param mode       The MASStorageMode to be used in the save
 *  @param completion The standard (BOOL success, NSError *error) completion block
 */
+ (void)deleteObjectUsingKey:(NSString *)key
                        mode:(MASStorageMode)mode
                  completion:(void (^)(BOOL success, NSError *error))completion;

@end
