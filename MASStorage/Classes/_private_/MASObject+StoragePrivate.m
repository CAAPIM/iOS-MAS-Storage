//
//  MASObject+StoragePrivate.m
//  MASStorage
//
//  Created by Luis Sanches on 2015-12-23.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import "MASObject+StoragePrivate.h"

#import <MASFoundation/MASFoundation.h>
#import <objc/runtime.h>

//Storage response JSON Keys
#define kStorage_Item_ObjectIdKey      @"key"

# pragma mark - Property Constants

static NSString *const kMASStorageObjectIdPropertyKey = @"id"; // string
static NSString *const kMASStorageAttributesPropertyKey = @"attributes"; // json
static NSString *const kMASStorageObjectIsNewPropertyKey = @"isNew"; // bool


@implementation MASObject (StoragePrivate)


# pragma mark - Properties

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (NSString *)objectId
{
    return objc_getAssociatedObject(self, &kMASStorageObjectIdPropertyKey);
}

- (void)setObjectId:(NSString *)objectId
{
    objc_setAssociatedObject(self, &kMASStorageObjectIdPropertyKey, objectId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (NSDictionary *)_attributes
{
    return objc_getAssociatedObject(self, &kMASStorageAttributesPropertyKey);
}

- (void)set_attributes:(NSDictionary *)attributes
{
    objc_setAssociatedObject(self, &kMASStorageAttributesPropertyKey, attributes, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isNew
{
    NSNumber *isNewNumber = objc_getAssociatedObject(self, &kMASStorageObjectIsNewPropertyKey);
    
    return [isNewNumber boolValue];
}

- (void)setIsNew:(BOOL)isNew
{
    objc_setAssociatedObject(self, &kMASStorageObjectIsNewPropertyKey, [NSNumber numberWithBool:isNew], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


# pragma mark - Lifecycle

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super init];
    
    if (!self) {
        
        return nil;
    }
    
    self.isNew = NO;
    self.objectId       = [attributes valueForKey:kStorage_Item_ObjectIdKey];
    self._attributes    = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    
    if ([attributes objectForKey:kMASStorageObjectIsNewPropertyKey]) {

        self.isNew = YES;
    }
    
    return self;
}

@end
