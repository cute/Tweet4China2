//
//  HSUUserHomeDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUUserHomeDataSource.h"

@implementation HSUUserHomeDataSource

- (id)fetchRefreshData
{
    id result = [TWENGINE getTimelineForUser:self.screenName isID:NO count:self.requestCount];
    if ([result isKindOfClass:[NSArray class]]) {
        NSDictionary *tweet = [result lastObject];
        self.lastStatsuID = tweet[@"id_str"];
    }
    return result;
}

- (id)fetchMoreData
{
    id result = [TWENGINE getTimelineForUser:self.screenName isID:NO count:self.requestCount sinceID:nil maxID:self.lastStatsuID];
    if (![result isKindOfClass:[NSArray class]]) {
        NSDictionary *tweet = [result lastObject];
        self.lastStatsuID = tweet[@"id_str"];
    }
    return result;
}

- (void)saveCache
{
    
}

@end
