//
//  HSUFollowingDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUFollowingDataSource.h"

@implementation HSUFollowingDataSource

-(id)fetchData
{
    return [TWENGINE getFollowingSinceId:self.nextCursor forUserScreenName:self.screenName];
}

@end
