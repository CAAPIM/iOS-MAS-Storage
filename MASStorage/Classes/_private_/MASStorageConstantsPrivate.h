//
//  MASStorageConstantsPrivate.h
//  MASStorage
//
//  Copyright (c) 2016 CA. All rights reserved.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#ifndef MASStorageConstantsPrivate_h
#define MASStorageConstantsPrivate_h


#endif /* MASStorageConstantsPrivate_h */

static NSString *const MASStorageEndPointKey = @"mas-storage-path"; // string

#define kSDKErrorDomain     @"com.ca.MASStorage:ErrorDomain"

typedef NS_ENUM (NSUInteger, MASStorageError)
{
    MASStorageErrorObjectNotSupported = 101,
    MASStorageErrorLocalStorageNotEnabled = 102,
};