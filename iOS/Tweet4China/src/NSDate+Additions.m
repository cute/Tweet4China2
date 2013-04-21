//
//  NSDate+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "NSDate+Additions.h"

@implementation NSDate (Additions)

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
    } else if (interval < 3600 * 24 * 7) {
        return [NSString stringWithFormat:@"%gd", ceil((cur-then)/3600/24)];
    } else {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterShortStyle];
        return [df stringFromDate:self];
    }
}

- (NSString *)standardTwitterDisplay
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    return [df stringFromDate:self];
}

@end