//
//  MASSecureStorage.m
//  MASStorage
//
//  Created by Luis Sanches on 2015-12-10.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import "MASSecureStorage.h"

#import "MASCloudStorage.h"
#import "MASLocalStorage.h"


@implementation MASSecureStorage


#pragma mark -
# pragma mark ------ Local Storage ------


# pragma mark - Local Storage Delete

+ (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    [MASLocalStorage deleteAllObjectsFromLocalStorageWithCompletion:completion];
}


+ (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASLocalStorage deleteObjectFromLocalStorageUsingKey:key completion:completion];
}


# pragma mark - Local Storage Find

+ (void)findObjectsFromLocalStorageUsingTag:(NSString *)tag
                                 completion:(void (^)(NSArray *objects, NSError *error))completion
{
    [MASLocalStorage findObjectsFromLocalStorageUsingTag:tag completion:completion];
}


# pragma mark - Local Storage Get

+ (void)getObjectFromLocalStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion
{
    [MASLocalStorage getObjectFromLocalStorageUsingKey:key completion:completion];
}


+ (void)getObjectsFromLocalStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    [MASLocalStorage getObjectsFromLocalStorageCompletion:completion];
}


# pragma mark - Local Storage Save

+ (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASLocalStorage saveToLocalStorageObject:object withKey:key andType:type completion:completion];
}


+ (void)saveToLocalStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                            type:(NSString *)type
           passwordForEncryption:(NSString *)password
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASLocalStorage saveToLocalStorageObject:object withKey:key type:type passwordForEncryption:password completion:completion];
}


# pragma mark - Local Storage Update

+ (void)updateToLocalStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASLocalStorage updateToLocalStorageObject:object withKey:key andType:type completion:completion];
}


#pragma mark -
# pragma mark ------ Cloud Storage ------


# pragma mark - Cloud Storage Delete

+ (void)deleteObjectFromCloudStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASCloudStorage deleteObjectFromCloudStorageUsingKey:key completion:completion];
}


# pragma mark - Cloud Storage Get

+ (void)getObjectFromCloudStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion
{
    [MASCloudStorage getObjectFromCloudStorageUsingKey:key completion:completion];
}


+ (void)getObjectsFromCloudStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    [MASCloudStorage getObjectsFromCloudStorageCompletion:completion];
}


# pragma mark - Cloud Storage Save

+ (void)saveToCloudStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASCloudStorage saveToCloudStorageObject:object withKey:key andType:type completion:completion];
}


# pragma mark - Cloud Storage Update

+ (void)updateToCloudStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    [MASCloudStorage updateToCloudStorageObject:object withKey:key andType:type completion:completion];
}

@end
