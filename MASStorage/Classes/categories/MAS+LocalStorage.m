//
//  MAS+LocalStorage.m
//  MASStorage
//
//  Created by Luis Sanches on 2015-09-08.
//  Copyright (c) 2015 CA Technologies. All rights reserved.
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
