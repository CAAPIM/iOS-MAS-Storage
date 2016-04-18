//
//  MASObject+StoragePrivate.h
//  MASStorage
//
//  Created by Luis Sanches on 2015-12-23.
//  Copyright © 2015 CA Technologies. All rights reserved.
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
