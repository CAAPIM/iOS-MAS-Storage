////
////  MASSecureStorage.m
////  MASStorage
////
////  Copyright (c) 2016 CA, Inc.
////
////  This software may be modified and distributed under the terms
////  of the MIT license. See the LICENSE file for details.
////
//
//#import "MASSecureStorage.h"
//
//#import "MASCloudStorage.h"
//#import "MASLocalStorage.h"
//
//
//@implementation MASSecureStorage
//
//
//+ (void)findObjectUsingKey:(NSString *)key
//                      mode:(MASStorageMode)mode
//                completion:(void (^)(MASObject *object, NSError *error))completion
//{
//    //Check Networking
//    if ([MAS gatewayIsReachable]) {
//        
//        //Call Cloud Storage
//        [MASCloudStorage findObjectUsingKey:key mode:mode completion:^(MASObject *object, NSError *error) {
//            
//            if (!error) {
//                
//                //Sync to Local Storage
//                
//                
//            }else {
//                
//                //Return error
//                if (completion) completion(object,error);
//            }
//        }];
//    }
//    else {
//        
//        //Use Local Storage
//        NSLog(@"////////////////////////// \n USING LOCAL STORAGE \n //////////////////////////");
//        
//        [MASLocalStorage findObjectUsingKey:key mode:mode completion:completion];
//    }
//}
//
//+ (void)findObjectsUsingMode:(MASStorageMode)mode
//                  completion:(void (^)(NSArray *objects, NSError *error))completion
//{
//    //Check Networking
//    if ([MAS gatewayIsReachable]) {
//        
//        //Call Cloud Storage
//        [MASCloudStorage findObjectsUsingMode:mode completion:^(NSArray *objects, NSError *error) {
//            
//            if (!error) {
//                
//                //Sync to Local Storage
//                
//                
//            }else {
//                
//                //Return error
//                if (completion) completion(nil,error);
//            }
//        }];
//    }
//    else {
//        
//        //Use Local Storage
//        NSLog(@"////////////////////////// \n USING LOCAL STORAGE \n //////////////////////////");
//        
//        [MASLocalStorage findObjectsUsingMode:mode completion:completion];
//    }
//}
//
//
//+ (void)saveObject:(NSObject *)object
//           withKey:(NSString *)key
//              type:(NSString *)type
//              mode:(MASStorageMode)mode
//        completion:(void (^)(BOOL success, NSError *error))completion
//{
//    //Check Networking
//    if ([MAS gatewayIsReachable]) {
//        
//        //Call Cloud Storage
//        [MASCloudStorage saveObject:object withKey:key type:type mode:mode completion:^(BOOL success, NSError *error) {
//            
//            if (!error) {
//                
//                //Sync to Local Storage
//                
//                
//            }else {
//                
//                //Return error
//                if (completion) completion(NO,error);
//            }
//        }];
//    }
//    else {
//        
//        //Use Local Storage
//        NSLog(@"////////////////////////// \n USING LOCAL STORAGE \n //////////////////////////");
//        
//        [MASLocalStorage saveObject:object withKey:key type:type mode:mode completion:completion];
//    }
//}
//
//
//+ (void)deleteObjectUsingKey:(NSString *)key
//                        mode:(MASStorageMode)mode
//                  completion:(void (^)(BOOL success, NSError *error))completion
//{
//    //Check Networking
//    if ([MAS gatewayIsReachable]) {
//        
//        //Call Cloud Storage
//        [MASCloudStorage deleteObjectUsingKey:key mode:mode completion:^(BOOL success, NSError *error) {
//            
//            if (!error) {
//                
//                //Sync to Local Storage
//                
//                
//            }else {
//                
//                //Return error
//                if (completion) completion(NO,error);
//            }
//        }];
//    }
//    else {
//        
//        //Use Local Storage
//        NSLog(@"////////////////////////// \n USING LOCAL STORAGE \n //////////////////////////");
//        
//        [MASLocalStorage deleteObjectUsingKey:key mode:mode completion:completion];
//    }
//}
//
//
//
//
//
//
//
//
//
//
//
//
//#pragma mark -
//# pragma mark ------ Local Storage ------
//
//
//# pragma mark - Local Storage Delete
//
//+ (void)deleteAllObjectsFromLocalStorageWithCompletion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASLocalStorage deleteAllObjectsFromLocalStorageWithCompletion:completion];
//}
//
//
//+ (void)deleteObjectFromLocalStorageUsingKey:(NSString *)key
//                                  completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASLocalStorage deleteObjectFromLocalStorageUsingKey:key completion:completion];
//}
//
//
//# pragma mark - Local Storage Find
//
//+ (void)findObjectsFromLocalStorageUsingTag:(NSString *)tag
//                                 completion:(void (^)(NSArray *objects, NSError *error))completion
//{
//    [MASLocalStorage findObjectsFromLocalStorageUsingTag:tag completion:completion];
//}
//
//
//# pragma mark - Local Storage Get
//
//+ (void)getObjectFromLocalStorageUsingKey:(NSString *)key
//                               completion:(void (^)(MASObject *object, NSError *error))completion
//{
//    [MASLocalStorage getObjectFromLocalStorageUsingKey:key completion:completion];
//}
//
//
//+ (void)getObjectsFromLocalStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
//{
//    [MASLocalStorage getObjectsFromLocalStorageCompletion:completion];
//}
//
//
//# pragma mark - Local Storage Save
//
//+ (void)saveToLocalStorageObject:(NSObject *)object
//                         withKey:(NSString *)key
//                         andType:(NSString *)type
//                      completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASLocalStorage saveToLocalStorageObject:object withKey:key andType:type completion:completion];
//}
//
//
//+ (void)saveToLocalStorageObject:(NSObject *)object
//                         withKey:(NSString *)key
//                            type:(NSString *)type
//           passwordForEncryption:(NSString *)password
//                      completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASLocalStorage saveToLocalStorageObject:object withKey:key type:type passwordForEncryption:password completion:completion];
//}
//
//
//# pragma mark - Local Storage Update
//
//+ (void)updateToLocalStorageObject:(NSObject *)object
//                           withKey:(NSString *)key
//                           andType:(NSString *)type
//                        completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASLocalStorage updateToLocalStorageObject:object withKey:key andType:type completion:completion];
//}
//
//
//#pragma mark -
//# pragma mark ------ Cloud Storage ------
//
//
//# pragma mark - Cloud Storage Delete
//
//+ (void)deleteObjectFromCloudStorageUsingKey:(NSString *)key
//                                  completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASCloudStorage deleteObjectFromCloudStorageUsingKey:key completion:completion];
//}
//
//
//# pragma mark - Cloud Storage Get
//
//+ (void)getObjectFromCloudStorageUsingKey:(NSString *)key
//                               completion:(void (^)(MASObject *object, NSError *error))completion
//{
//    [MASCloudStorage getObjectFromCloudStorageUsingKey:key completion:completion];
//}
//
//
//+ (void)getObjectsFromCloudStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
//{
//    [MASCloudStorage getObjectsFromCloudStorageCompletion:completion];
//}
//
//
//# pragma mark - Cloud Storage Save
//
//+ (void)saveToCloudStorageObject:(NSObject *)object
//                         withKey:(NSString *)key
//                         andType:(NSString *)type
//                      completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASCloudStorage saveToCloudStorageObject:object withKey:key andType:type completion:completion];
//}
//
//
//# pragma mark - Cloud Storage Update
//
//+ (void)updateToCloudStorageObject:(NSObject *)object
//                           withKey:(NSString *)key
//                           andType:(NSString *)type
//                        completion:(void (^)(BOOL success, NSError *error))completion
//{
//    [MASCloudStorage updateToCloudStorageObject:object withKey:key andType:type completion:completion];
//}
//
//@end
