//
//  HSUHomeDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUHomeDataSource.h"
#import "FHSTwitterEngine.h"

@implementation HSUHomeDataSource
{
    FHSTwitterEngine *twEngine;
}

- (id)init
{
    self = [super init];
    if (self) {
        twEngine = [[FHSTwitterEngine alloc] initWithConsumerKey:kTwitterAppKey andSecret:kTwitterAppSecret];
        [twEngine loadAccessToken];
    }
    return self;
}

- (void)authenticate
{
    if (!twEngine.isAuthorized) {
        [twEngine showOAuthLoginControllerFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
        return;
    }
}

- (void)refresh
{
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            id result = [twEngine getHomeTimelineSinceID:@"1" count:20];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    if ([result isKindOfClass:[NSError class]]) {
                        [weakSelf.delegate dataSource:weakSelf didFinishUpdateWithError:result];
                    } else {
                        NSArray *tweets = result;
                        for (int i=tweets.count-1; i>=0; i--) {
                            NSDictionary *tweet = tweets[i];
                            NSDictionary *rowData = @{@"data_type": @"Status", @"cell_data": tweet};
                            [self.data insertObject:rowData atIndex:0];
                        }
                        [weakSelf.delegate dataSource:weakSelf didFinishUpdateWithError:nil];
                    }
                }
            });
        }
    });
}

@end
