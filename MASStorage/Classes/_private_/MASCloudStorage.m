//
//  MASCloudStorage.m
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MASCloudStorage.h"

#import <MASFoundation/MASFoundation.h>
#import "MASObject+MASStorage.h"
#import "MASObject+StoragePrivate.h"
#import "MASStorageConstantsPrivate.h"


@implementation MASCloudStorage


# pragma mark - Delete

+ (void)deleteObjectFromCloudStorageUsingKey:(NSString *)key
                                  completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(key);
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/%@/Data/%@",[[MASConfiguration currentConfiguration] endpointPathForKey:MASStorageEndPointKey],[MASApplication currentApplication].identifier,key];


    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS deleteFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {

        DLog(@"(MASCloudStorage deleteObjects) received response info:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            if (completion) {
                
                completion(YES,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(NO,error);
            }
        }
    }];
}


# pragma mark - Get

+ (void)getObjectFromCloudStorageUsingKey:(NSString *)key
                               completion:(void (^)(MASObject *object, NSError *error))completion
{
    NSParameterAssert(key);
    
    
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/%@/Data/%@",[[MASConfiguration currentConfiguration] endpointPathForKey:MASStorageEndPointKey],[MASApplication currentApplication].identifier,key];
    
    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASCloudStorage getObjectWithKey) received response info:\n\n%@\n\n", responseInfo);

        NSMutableDictionary* responseDict = [[NSMutableDictionary alloc] init];

        if (!error) {
            
            NSMutableDictionary *response =  [[NSMutableDictionary alloc] initWithDictionary:[responseInfo valueForKey:MASResponseInfoBodyInfoKey]];
            
            //
            //Check if there is any "value" key in the dictionary (it is default base64 encoded)
            //
            if ([response objectForKey:@"value"]) {
                
                //Decode data
                NSString *base64String = [response objectForKey:@"value"];
                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
               
                NSError *errorJson=nil;
                
                responseDict = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:decodedData options:kNilOptions error:&errorJson]];

                NSData *decodedData2 = [[NSData alloc] initWithBase64EncodedString:[responseDict objectForKey:@"value"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                
                if (decodedData2) {

                    [responseDict setObject:decodedData2 forKey:@"value"];
                }
            }
            
            
            //
            //Parse the response into MASObject object
            //
            MASObject *object = [[MASObject alloc] initWithAttributes:(NSDictionary *)responseDict];
            
            
            if (completion) {
                
                completion(object,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(nil,error);
            }
        }
    }];

}


+ (void)getObjectsFromCloudStorageCompletion:(void (^)(NSArray *objects, NSError *error))completion
{
    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/%@/Data",[[MASConfiguration currentConfiguration] endpointPathForKey:MASStorageEndPointKey],[MASApplication currentApplication].identifier];

    
    //
    //Use MAS Object to make the security call to the Gateway
    //
    [MAS getFrom:pathURL withParameters:nil andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASCloudStorage getObjects) received response info:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            NSMutableArray *list = [[NSMutableArray alloc] init];
            
            NSArray *responseList = [[responseInfo valueForKey:MASResponseInfoBodyInfoKey] valueForKey:@"results"];
            
            for (NSDictionary *response in responseList) {

                //
                //Parse the response into MASObject object
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


# pragma mark - Save

+ (void)saveToCloudStorageObject:(NSObject *)object
                         withKey:(NSString *)key
                         andType:(NSString *)type
                      completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);

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
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/%@/Data/%@",[[MASConfiguration currentConfiguration] endpointPathForKey:MASStorageEndPointKey],[MASApplication currentApplication].identifier,key];
    
    //
    //Build Parameters
    //
    NSString *base64String = [encodeData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *params = @{@"value":base64String,
                             @"type":type,
                             @"key":key};
    
    [MAS postTo:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASCloudStorage SaveToCloud) received response info:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            if (completion) {
                
                completion(YES,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(NO,error);
            }
        }
    }];
}


# pragma mark - Update

+ (void)updateToCloudStorageObject:(NSObject *)object
                           withKey:(NSString *)key
                           andType:(NSString *)type
                        completion:(void (^)(BOOL success, NSError *error))completion
{
    NSParameterAssert(object);
    NSParameterAssert(key);
    NSParameterAssert(type);
    
    //
    // Validate the Message object. Only NSString and NSData are supported
    //
    __block NSData *encodeData;
    if ([object isKindOfClass:[NSString class]]) {
        
        encodeData = [(NSString *)object dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([object isKindOfClass:[NSData class]]) {
        
        encodeData = (NSData *)object;
    }
    else if (completion) {
        
        NSString *message = NSLocalizedString(@"Message object not supported", @"Message object not supported");
        NSError *localizedError = [NSError errorWithDomain:kSDKErrorDomain
                                                      code:MASStorageErrorObjectNotSupported
                                                  userInfo:@{ NSLocalizedDescriptionKey : message }];
        
        completion(NO, localizedError);
        
        return;
    }

    //
    //Build the PathURL
    //
    NSString *pathURL = [NSString stringWithFormat:@"%@/%@/Data/%@",[[MASConfiguration currentConfiguration] endpointPathForKey:MASStorageEndPointKey],[MASApplication currentApplication].identifier,key];
    
    //
    //Build Parameters
    //
    NSString *base64String = [encodeData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSDictionary *params = @{@"value":base64String,
                             @"type":type,
                             @"key":key};
    
    [MAS putTo:pathURL withParameters:params andHeaders:nil completion:^(NSDictionary *responseInfo, NSError *error) {
        
        DLog(@"(MASCloudStorage UpdateToCloud) received response info:\n\n%@\n\n", responseInfo);
        
        if (!error) {
            
            if (completion) {
                
                completion(YES,nil);
            }
        }
        else {
            
            if (completion) {
                
                completion(NO,error);
            }
        }
    }];
}

@end
