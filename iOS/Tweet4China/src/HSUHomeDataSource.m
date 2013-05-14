//
//  HSUHomeDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUHomeDataSource.h"

@implementation HSUHomeDataSource

+ (void)checkUnreadForViewController:(HSUBaseViewController *)viewController
{
#ifdef AUTHOR_jason
    return;
#endif
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSString *latestIdStr = [[NSUserDefaults standardUserDefaults] objectForKey:S(@"%@_first_id_str", self.cacheKey)];
            if (!latestIdStr) {
                latestIdStr = @"1";
            }
            id result = [TWENGINE getHomeTimelineSinceID:latestIdStr count:1];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    if (![result isKindOfClass:[NSError class]]) {
                        NSArray *tweets = result;
                        NSString *lastIdStr = tweets.lastObject[@"id_str"];
                        if (lastIdStr) { // updated
                            [viewController dataSourceDidFindUnread:nil];
                        }
                    } else {
                        
                    }
                }
            });
        }
    });
}

- (id)fetchRefreshData
{
    NSString *latestIdStr = [self rawDataAtIndex:0][@"id_str"];
    if (!latestIdStr) {
        latestIdStr = @"1";
    }
    return [TWENGINE getHomeTimelineSinceID:latestIdStr count:self.requestCount];
}

- (id)fetchMoreData
{
    HSUTableCellData *lastStatusData = [self dataAtIndex:self.count-2];
    NSString *lastStatusId = lastStatusData.rawData[@"id_str"];
    return [TWENGINE getHomeTimelineMaxId:lastStatusId count:self.requestCount];
}

-(void)saveCache
{
    [super saveCache];
    
    if (self.count) {
        NSString *firstIdStr = [self rawDataAtIndex:0][@"id_str"];
        [[NSUserDefaults standardUserDefaults] setObject:firstIdStr forKey:S(@"%@_first_id_str", [self.class cacheKey])];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
