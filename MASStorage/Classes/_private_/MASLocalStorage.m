//
//  MASLocalStorage.m
//  MASStorage
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASLocalStorage.h"

#import <MASFoundation/MASFoundation.h>
#import <objc/runtime.h> //Used for the dynamic getter and setter inside a Category.
#import "MASDatabase.h"
#import "MASStorageConstants.h"
#import "MASStorageConstantsPrivate.h"
#import "NSError+MASStoragePrivate.h"

static void *masDatabasePropertyKey;



@interface MASLocalStorage ()

extern MASLocalStorage *_sharedStorage;

@property (nonatomic, strong) MASDatabase *masDatabase;

@end


@implementation MASLocalStorage

MASLocalStorage *_sharedStorage = nil;


# pragma mark - Lifecycle

+ (instancetype)enableLocalStorage
{
    static dispatch_once_t onceToken;

    if (!_sharedStorage) {
        
        dispatch_once(&onceToken, ^{
            
            _sharedStorage = [[MASLocalStorage alloc] init];
            _sharedStorage.masDatabase = [MASDatabase sharedDatabase];
        });
    }
    
    return _sharedStorage;
}


#pragma mark - Private methods

- (MASDatabase *)masDatabase
{
    return objc_getAssociatedObject(self, &masDatabasePropertyKey);
}


- (void)setMasDatabase:(MASDatabase *)masDatabase
{
    objc_setAssociatedObject(self, &masDatabasePropertyKey, masDatabase, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark - Public methods
#pragma mark - Find methods

+ (void)findObjectUsingKey:(NSString *)key
                      mode:(MASLocalStorageSegment)mode
                completion:(void (^)(MASObject *object, NSError *error))completion
{
    //
    // Check for key parameter
    //
    if (!key)
    {
        
        NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(nil, localizedError);
        }
        
        return;
    }
    
    //
    // Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(nil,localizedError);
        }
        
        return;
    }
    
    //
    // MASDatabase Get method
    //
    [[MASDatabase sharedDatabase] findObjectUsingKey:key mode:mode completion:^(NSDictionary *response, NSError *error) {
        
        if (!error) {
            
            //
            //Parse the response into MASObject object
            //
            MASObject *object = [[MASObject alloc] initWithAttributes:(NSDictionary *)response];
            
            if (completion) {
                
                completion(object, error);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil,error);
            }
        }
    }];

}


+ (void)findObjectsUsingMode:(MASLocalStorageSegment)mode
                  completion:(void (^)(NSArray *objects, NSError *error))completion
{
    //
    // Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(nil,localizedError);
        }
        
        return;
    }
    
    //
    // MASDatabase Get method
    //
    [[MASDatabase sharedDatabase] findObjectsUsingMode:mode completion:^(NSArray *objects, NSError *error) {
        
        DLog(@"(MASLocalStorage getObjects) received response info:\n\n%@\n\n", objects);
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = objects;
            
            for (NSDictionary *response in responseList) {
                
                //
                // Parse the response into MASObject object
                //
                MASObject *object = [[MASObject alloc] initWithAttributes:(NSDictionary *)response];
                
                [list addObject:object];
            }
            
            if (completion) {
                
                completion(list,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil,error);
            }
        }
    }];
}


#pragma mark - Save/Update method

+ (void)saveObject:(NSObject *)object
           withKey:(NSString *)key
              type:(NSString *)type
              mode:(MASLocalStorageSegment)mode
        completion:(void (^)(BOOL success, NSError *error))completion
{
    //
    // Check for object, key, and type parameters
    //
    NSError *localizedError = nil;
    
    if (![self validateParametersObject:object key:key andType:type withError:&localizedError])
    {
        if (completion)
        {
            completion(NO, localizedError);
        }
        
        return;
    }
    
    
    
    //
    // Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(NO,localizedError);
        }
        
        return;
    }
    
    
    //
    // Validate the object. Only NSString and NSData are supported
    //
    __block NSData *encodeData;
    if ([object isKindOfClass:[NSString class]]) {
        
        encodeData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([object isKindOfClass:[NSData class]]) {
        
        encodeData = (NSData *)object;
    }
    else {
        
        if (completion) {
        
        NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorObjectNotSupported errorDomain:kSDKErrorDomain];
        
        completion(NO, localizedError);
            
        }
        
        return;
    }
    
    //
    //MASDatabase Save method
    //
    [[MASDatabase sharedDatabase] saveToLocalStorageObject:encodeData withKey:key andType:type mode:mode completion:^(BOOL success, NSError *error) {
        
        if (success) {

            if (completion) completion(success,error);
        }
        else {
            
            //
            // Call Update
            //
            [[MASDatabase sharedDatabase] updateToLocalStorageObject:encodeData withKey:key andType:type mode:mode completion:^(BOOL success, NSError *error) {
                
                if (completion) completion(success,error);
            }];
        }
    }];
}


+ (void)saveObject:(NSObject *)object
           withKey:(NSString *)key
              type:(NSString *)type
              mode:(MASLocalStorageSegment)mode
          password:(NSString *)password
        completion:(void (^)(BOOL success, NSError *error))completion
{
    //
    // Check for password parameter
    //
    if (!password)
    {
        NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(NO,localizedError);
        }
        
        return;
    }
    
    //
    //Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(NO,localizedError);
        }
        
        return;
    }
    
    //
    // Validate Null parameters
    //
    NSError *localizedError = nil;
    
    if (![self validateParametersObject:object key:key andType:type withError:&localizedError]) {
        
        if (completion) completion (NO, localizedError);
    }

    
    //
    // Validate the object. Only NSString and NSData are supported
    //
    __block NSData *encodeData;
    if ([object isKindOfClass:[NSString class]]) {
        
        encodeData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([object isKindOfClass:[NSData class]]) {
        
        encodeData = (NSData *)object;
    }
    else {
        
        if (completion) {
        
        NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorObjectNotSupported errorDomain:kSDKErrorDomain];
        
        completion(NO, localizedError);
        
        }
        
        return;
    }
    
    NSError *encryptionError;
    
    //
    //Encrypt Object before sending to the database
    //
    NSData *encryptedData = [NSData encryptData:encodeData password:password error:&encryptionError];
    
    
    //
    //Check if Encryption was successful
    //
    if (encryptionError) {
        
        if (completion) {
            
            completion(NO,encryptionError);
        }
        
        return;
    }
    
    //
    //MASDatabase Save method
    //
    [[MASDatabase sharedDatabase] saveToLocalStorageObject:encryptedData withKey:key andType:type mode:mode completion:^(BOOL success, NSError *error) {
        
        if (success) {
            
            if (completion) completion(success,error);
        }
        else {
            
            //
            // Call Update
            //
            [[MASDatabase sharedDatabase] updateToLocalStorageObject:encodeData withKey:key andType:type mode:mode completion:^(BOOL success, NSError *error) {
                
                if (completion) completion(success,error);
            }];
        }
    }];
}


#pragma mark - Delete methods

+ (void)deleteObjectUsingKey:(NSString *)key
                        mode:(MASLocalStorageSegment)mode
                  completion:(void (^)(BOOL success, NSError *error))completion
{
    //
    //Check for key parameter
    //
    if (!key)
    {
        NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        
        if (completion)
        {
            completion(NO, localizedError);
        }
        
        return;
    }
    
    //
    //Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(NO,localizedError);
        }
        
        return;
    }
    
    //
    //MASDatabase Delete method
    //
    [[MASDatabase sharedDatabase] deleteObjectUsingKey:key mode:mode completion:^(BOOL success, NSError *error) {
        
        if (completion) {
            
            completion(success, error);
        }
    }];
}

+ (void)deleteAllObjectsUsingMode:(MASLocalStorageSegment)mode
                       completion:(void (^)(BOOL success, NSError *error))completion
{
    //
    // Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage)
    {
        if (completion) {
            
            NSError *localizedError = [NSError errorForStorageErrorCode:MASStorageErrorLocalStorageNotEnabled errorDomain:kSDKErrorDomain];
            
            completion(NO,localizedError);
        }
        
        return;
    }
    
    //
    // Execute on MASDatabase
    //
    [[MASDatabase sharedDatabase] deleteAllObjectsUsingMode:mode completion:^(BOOL success, NSError *error) {

        if (completion) completion(success, error);
     }];
}

#pragma mark - Helper methods
 
+ (BOOL)validateParametersObject:(NSObject *)object
                             key:(NSString *)key
                         andType:(NSString *)type
                       withError:(NSError **)error
{
    if (!object || [object isKindOfClass:[NSNull class]]) {
        
        if (error)
        {
            *error = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        }
        
        return NO;
    }
    else if (!key || [key isKindOfClass:[NSNull class]]) {
        
        if (error)
        {
            *error = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        }
        
        return NO;
    }
    else if (!type || [type isKindOfClass:[NSNull class]]) {
        
        if (error)
        {
            *error = [NSError errorForStorageErrorCode:MASStorageErrorParameterCanNotBeEmptyOrNil errorDomain:kSDKErrorDomain];
        }
    
        return NO;
    }
    
    return YES;
}

@end
