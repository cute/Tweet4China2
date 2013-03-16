//
//  NSDate+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "NSDate+Addition.h"

@implementation NSDate (Addition)

- (NSString *)twitterDisplay
{
    NSTimeInterval cur = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval then = [self timeIntervalSince1970];
    NSTimeInterval interval = cur - then;
    if (interval < 60) {
        return [NSString stringWithFormat:@"%gs", ceil(cur-then)];
    } else if (interval < 3600) {
        return [NSString stringWithFormat:@"%gm", ceil((cur-then)/60)];
    } else if (interval < 3600 * 24) {
        return [NSString stringWithFormat:@"%gh", ceil((cur-then)/3600)];
    } else if (interval < 3600 * 24 * 30) {
        return [NSString stringWithFormat:@"%gd", ceil((cur-then)/3600/24)];
    } else if (interval < 3600 * 24 * 365) {
        return [NSString stringWithFormat:@"%gmon", ceil((cur-then)/3600/24/30)];
    } else {
        return [NSString stringWithFormat:@"%gy", ceil((cur-then)/3600/24/365)];
    }
}

@end
