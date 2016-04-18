//
//  MAS+LocalStorage.h
//  MASStorage
//
//  Created by Luis Sanches on 2015-09-08.
//  Copyright (c) 2015 CA Technologies. All rights reserved.
//

#import <MASFoundation/MASFoundation.h>


/**
 *  This category enables Local Storage feature
 */
@interface MAS (LocalStorage)


/**
 * Singleton instance of the MASLocalStorage. It creates the local storage database in
 * case it doesn't exist.
 *
 * @return MASLocalStorage singleton.
 */
+ (void)enableLocalStorage;

@end
