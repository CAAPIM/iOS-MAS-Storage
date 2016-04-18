//
//  MASObject+MASStorage.m
//  MASStorage
//
//  Created by Luis Sanches on 2015-12-24.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import "MASObject+MASStorage.h"

#import "MASCloudStorage.h"
#import "MASLocalStorage.h"
#import "MASObject+StoragePrivate.h"


@implementation MASObject (MASStorage)

#pragma mark - Instance Methods

- (instancetype)initWithKey:(NSString *)key value:(NSObject *)value type:(NSString *)type
{
    NSParameterAssert(key);
    NSParameterAssert(value);
    NSParameterAssert(type);
    
    NSDictionary *attributes = @{@"key":key,
                                 @"value":value,
                                 @"type":type,
                                 @"isNew":@YES};
    
    return [self initWithAttributes:attributes];
}


- (void)saveToCloudInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    //TODO: Add validations for parameters
    [MASCloudStorage saveToCloudStorageObject:[self objectForKey:@"value"] withKey:[self objectForKey:@"key"] andType:[self objectForKey:@"type"] completion:completion];
}


- (void)deleteFromCloudInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion
{
    //TODO: Add validations for parameters and if Object is NEW
    [MASCloudStorage deleteObjectFromCloudStorageUsingKey:[self objectForKey:@"key"] completion:completion];
}

#pragma mark - Print Attributes

- (void)listAttributes
{
    DLog(@"%@",self._attributes);
}

@end
