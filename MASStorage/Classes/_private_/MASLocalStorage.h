//
//  MASLocalStorage.h
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
 *  This class exposes Local Storage features
 */
@interface MASLocalStorage : NSObject


# pragma mark - Lifecycle

/**
 *  Singleton instance of MASLocalStorage.
 *
 *  It creates the local storage database in case it doesn't exist.
 *
 *  @return Singleton instance of MASLocalStorage.
 */
+ (instancetype)enableLocalStorage;






+ (void)findObjectUsingKey:(NSString *)key
                      mode:(MASStorageMode)mode
                completion:(void (^)(MASObject *object, NSError *error))completion;


+ (void)findObjectsUsingMode:(MASStorageMode)mode
                  completion:(void (^)(NSArray *objects, NSError *error))completion;


+ (void)saveObject:(NSObject *)object
           withKey:(NSString *)key
              type:(NSString *)type
              mode:(MASStorageMode)mode
        completion:(void (^)(BOOL success, NSError *error))completion;


+ (void)deleteObjectUsingKey:(NSString *)key
                        mode:(MASStorageMode)mode
                  completion:(void (^)(BOOL success, NSError *error))completion;









# pragma mark - Delete

/**
 *  Delete ALL objects from local storage.
 *
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion;


/**
 *  Delete an object from Local Storage based on a given key.
 *
 *  @param key        The key used to delete the object from the storage.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion;


# pragma mark - Find

/**
 *  Find objects in Local Storage based on a tag.
 *
 *  @param tag        The tag used to find objects from local storage.
 *  @param completion A (NSArray *objects, NSError *error) completion block.
 */
+ (void)findObjectsFromLocalStorageUsingTag:(NSString *)tag
                                 completion:(void (^)(NSArray *objects, NSError *error))completion;


# pragma mark - Get

/**
 *  Get an object from Local Storage based on a specific key.
 *
 *  @param key        The key used to get the object from local storage.
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


# pragma mark - Save

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
 *  Save an object with encryption to Local Storage.
 *
 *  @param object     Object to be saved. It must conform to NSObject.
 *  @param key        Key to be used when saving the object.
 *  @param type       Type of the Object been saved.
 *  @param password   Password used for encryption.
 *  @param completion The standard (BOOL success, NSError *error) completion block.
 */
+ (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                            type:(NSString *)type
           passwordForEncryption:(NSString *)password
                      completion:(void (^)(BOOL success, NSError *error))completion;


# pragma mark - Update

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

@end
