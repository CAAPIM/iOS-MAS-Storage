//
//  MASSecureStorage.h
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
 *  This class exposes features for Local and Cloud Storage.
 */
@interface MASSecureStorage : NSObject


#pragma mark -
# pragma mark ------ Cloud Storage ------


///--------------------------------------
/// @name Local Storage Delete
///--------------------------------------

# pragma mark - Local Storage Delete

/**
 *  Delete all objects from Local Storage.
 *
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Delete an object from Local Storage based on a given key.
 *
 *  @param key        The Key used to delete the object from local storage.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion;



///--------------------------------------
/// @name Local Storage Find
///--------------------------------------

# pragma mark - Local Storage Find

/**
 *  Find objects in Local Storage based on a tag.
 *
 *  @param tag        The tag used to find objects from local storage.
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
+ (void)findObjectsFromLocalStorageUsingTag:(NSString *)tag
                                 completion:(void (^)(NSArray *objects, NSError *error))completion;



///--------------------------------------
/// @name Local Storage Get
///--------------------------------------

# pragma mark - Local Storage Get

/**
 *  Get an object from Local Storage based in a specific key.
 *
 *  @param key        The Key used to get the object from local storage.
 *  @param completion A (MASObject *object, NSError *error) completion block.
 */
+ (void)getObjectFromLocalStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion;


/**
 *  Get all objects from Local Storage.
 *
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
+ (void)getObjectsFromLocalStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion;



///--------------------------------------
/// @name Local Storage Save
///--------------------------------------

# pragma mark - Local Storage Save

/**
 *  Save an object into Local Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                      completion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Encrypt an object and save it into Local Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param password   Password used for encryption.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                            type:(NSString *)type
           passwordForEncryption:(NSString *)password
                      completion:(void (^)(BOOL success, NSError *error))completion;



///--------------------------------------
/// @name Local Storage Update
///--------------------------------------

# pragma mark - Local Storage Update

/**
 *  Update an object into Local Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the object been saved.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)updateToLocalStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                        completion:(void (^)(BOOL success, NSError *error))completion;


#pragma mark -
# pragma mark ------ Cloud Storage ------


///--------------------------------------
/// @name Cloud Storage Delete
///--------------------------------------

# pragma mark - Cloud Storage Delete

/**
 *  Delete an Object from Cloud Storage based on a given key.
 *
 *  @param key        The Key used to delete the object from cloud storage.
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
+ (void)deleteObjectFromCloudStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion;



///--------------------------------------
/// @name Cloud Storage Get
///--------------------------------------

# pragma mark - Cloud Storage Get


/**
 *  Get an object from Cloud Storage based on a specific key.
 *
 *  @param key        The Key used to get the object from cloud storage.
 *  @param completion Return Block with the Object if success or Error if not
 */
+ (void)getObjectFromCloudStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion;


/**
 *  Get all objects from Cloud Storage.
 *
 *  @param completion Return Block with the Array of Objects if success or Error if not
 */
+ (void)getObjectsFromCloudStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion;



///--------------------------------------
/// @name Cloud Storage Save
///--------------------------------------

# pragma mark - Cloud Storage Save

/**
 *  Save an object into Cloud Storage
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



///--------------------------------------
/// @name Cloud Storage Update
///--------------------------------------

# pragma mark - Cloud Storage Update

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
