//
//  MASLocalStorage.m
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASLocalStorage.h"

#import <MASFoundation/MASFoundation.h>
#import <objc/runtime.h> //Used for the dynamic getter and setter inside a Category.
#import "MASDatabase.h"
#import "MASObject+StoragePrivate.h"
#import "MASStorageConstants.h"
#import "MASStorageConstantsPrivate.h"

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
    NSParameterAssert(key);
    
    //
    // Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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
            
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);
    
    //
    //Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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
    else if (completion) {
        
        NSString *message = NSLocalizedString(@"Object not supported", @"Object not supported");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorObjectNotSupported
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        completion(NO, localizedError);
        
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
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);
    NSParameterAssert(password);
    
    //
    //Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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
    else if (completion) {
        
        NSString *message = NSLocalizedString(@"Object not supported", @"Object not supported");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorObjectNotSupported
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        completion(NO, localizedError);
        
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
    NSParameterAssert(key);
    
    //
    //Check if MASLocalStorage was enabled
    //
    if (!_sharedStorage) {
        
        if (completion) {
            
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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
         
            NSString *message = NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                          code:MASStorageErrorLocalStorageNotEnabled
                                                      userInfo:@{ NSLocalizedDescriptionKey : message }];
            
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

@end
