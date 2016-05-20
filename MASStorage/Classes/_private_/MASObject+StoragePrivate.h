//
//  MASObject+StoragePrivate.h
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import <MASFoundation/MASFoundation.h>


@interface MASObject (StoragePrivate)


# pragma mark - Properties

@property (nonatomic, copy, readwrite) NSString *objectId;
@property (nonatomic, copy, readwrite) NSMutableDictionary *_attributes;
@property (nonatomic, assign, readwrite) BOOL isNew;


# pragma mark - Lifecycle

/**
 *  Init the object with passed attributes in a form of NSDictionary
 *
 *  @param attributes NSDictionary to be used as attributes
 *
 *  @return The instance of the MASObject object
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
