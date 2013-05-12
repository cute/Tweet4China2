//
//  HSUNetworkActivityIndicatorManager.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/19/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUNetworkActivityIndicatorManager.h"

static uint indicatorCount = 0;
@implementation HSUNetworkActivityIndicatorManager

+ (void)show
{
    indicatorCount ++;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

+ (void)hide
{
    if (indicatorCount > 0) {
        indicatorCount --;
    }
    if (indicatorCount == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
