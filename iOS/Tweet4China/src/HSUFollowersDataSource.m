//
//  HSUFollowersDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUFollowersDataSource.h"

@implementation HSUFollowersDataSource

- (id)fetchData
{
    return [TWENGINE getFollowersSinceId:self.nextCursor forUserScreenName:self.screenName];
}

@end
