//
//  HSUCommonTools.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "HSUCommonTools.h"

@implementation HSUCommonTools

+ (BOOL)isIPhone
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isIPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (CGFloat)winWidth
{
    return [[UIScreen mainScreen] bounds].size.width;
}

+ (CGFloat)winHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

@end
