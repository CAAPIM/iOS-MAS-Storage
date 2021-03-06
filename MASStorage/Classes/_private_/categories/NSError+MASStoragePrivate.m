//
//  NSError+MASStoragePrivate.m
//  MASStorage
//
//  Created by Hun Go on 2016-11-17.
//  Copyright © 2016 CA Technologies. All rights reserved.
//

#import "NSError+MASStoragePrivate.h"

@implementation NSError (MASStoragePrivate)

+ (NSError *)errorForStorageErrorCode:(MASStorageError)errorCode errorDomain:(NSString *)errorDomain
{
    return [self errorForStorageErrorCode:errorCode info:nil errorDomain:errorDomain];
}


+ (NSError *)errorForStorageErrorCode:(MASStorageError)errorCode info:(NSDictionary *)info errorDomain:(NSString *)errorDomain
{
    //
    // Standard error key/values
    //
    NSMutableDictionary *errorInfo = [NSMutableDictionary new];
    if(![info objectForKey:NSLocalizedDescriptionKey])
    {
        errorInfo[NSLocalizedDescriptionKey] = [self descriptionForStorageErrorCode:errorCode];
    }
    
    [errorInfo addEntriesFromDictionary:info];
    
    return [NSError errorWithDomain:errorDomain code:errorCode userInfo:errorInfo];
}


+ (NSString *)descriptionForStorageErrorCode:(MASStorageError)errorCode
{
    //
    // Detect code and respond appropriately
    //
    switch (errorCode)
    {
            //
            // Storage object
            //
        case MASStorageErrorObjectNotSupported: return NSLocalizedString(@"Object not supported", @"Object not supported");
        case MASStorageErrorParameterCanNotBeEmptyOrNil: return NSLocalizedString(@"Missing parameter - parameter cannot be empty or nil", @"Missing parameter - parameter cannot be empty or nil");
            
        case MASStorageErrorInvalidEndpoint: return NSLocalizedString(@"Storage endpoint in the configuration is invalid or missing.", @"Storage endpoint in the configuration is invalid or missing.");
            
            //
            // Local Storage
            //
        case MASStorageErrorLocalStorageNotEnabled: return NSLocalizedString(@"Local Storage not enabled. Please call [MAS enableLocalStorage] to start using Local Storage", nil);
            
        default: return [NSString stringWithFormat:@"Unrecognized error code of value: %ld", (long)errorCode];
    }
}

@end
