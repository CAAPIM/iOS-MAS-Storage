//
//  MASStorageConstants.h
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#ifndef MASStorageConstants_h
#define MASStorageConstants_h


#endif /* MASStorageConstants_h */

/**
 *  Storage Modes
 */
typedef NS_ENUM(NSInteger, MASStorageMode) {
    /**
     *  Unknown Mode
     */
    MASStorageModeUnknown = -1,
    /**
     *  Data in this mode is stored and available to a specific User ONLY
     */
    MASStorageModeUser,
    /**
     *  Data in this mode is stored and available in an Application Level
     */
    MASStorageModeApplication,
    /**
     *  Data in this mode is stored and available in an Application for a specific User
     */
    MASStorageModeApplicationForUser
};



/**
 *  Sync Modes
 */
typedef NS_ENUM(NSInteger, SyncMode) {
    /**
     *  Unknown Mode
     */
    MASStorageSyncModeUnknown = -1,
    /**
     *  Sync Local and Cloud Storage automatically
     */
    MASStorageSyncModeAutomatically,
    /**
     *  Sync Local and Cloud Storage manually. Please refer to [MASSecureStorage syncStorages] for more details
     */
    MASStorageSyncModeManually,
};