//
//  MAS+LocalStorage.m
//  MASStorage
//
//  Copyright (c) 2016 CA, Inc.
//
//  This software may be modified and distributed under the terms
//  of the MIT license. See the LICENSE file for details.
//

#import "MAS+LocalStorage.h"

#import <MASFoundation/MASFoundation.h>
#import "MASLocalStorage.h"


@implementation MAS (LocalStorage)


+ (void)enableLocalStorage
{
    [MASLocalStorage enableLocalStorage];
}

@end
