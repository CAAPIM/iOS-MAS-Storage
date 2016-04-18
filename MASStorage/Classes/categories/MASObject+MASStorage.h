//
//  MASObject+MASStorage.h
//  MASStorage
//
//  Created by Luis Sanches on 2015-12-24.
//  Copyright © 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>


/**
 *  This category enables Local Storage feature to the MASObject
 */
@interface MASObject (MASStorage)


#pragma mark - Instance Methods


/**
 *  Init the MASObject with a Key, Value, and Type
 *
 *  @param key   The string to use as key for the data to be stored
 *  @param value The data value to be stored
 *  @param type  The type of the data
 *
 *  @return The instance of the MASObject object with the passed attributes
 */
- (instancetype)initWithKey:(NSString *)key value:(NSObject *)value type:(NSString *)type;



/**
 *  Saves the object in the cloud.
 *
 *  @param completion Completion block with either the MASObject object or the Error message
 */
- (void)saveToCloudInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion;



/**
 *  Deletes the object from the cloud.
 *
 *  @param completion Completion block with either Success boolean or the Error message
 */
- (void)deleteFromCloudInBackgroundWithCompletion:(void (^)(BOOL success, NSError *error))completion;


#pragma mark - Print Attributes

/**
 *  List all attributes from the Object
 */
- (void)listAttributes;

@end
