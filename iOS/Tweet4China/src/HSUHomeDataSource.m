//
//  HSUHomeDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUHomeDataSource.h"
#import "FHSTwitterEngine.h"
#import "HSUStatusCell.h"
#import "TTTAttributedLabel.h"
#import "HSUTableCellData.h"

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
    [super refresh];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            NSString *latestIdStr = [self rawDataAtIndex:0][@"id_str"];
            if (!latestIdStr) {
                latestIdStr = @"1";
            }
            id result = [twEngine getHomeTimelineSinceID:latestIdStr count:200];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    if ([result isKindOfClass:[NSError class]]) {
                        [weakSelf.delegate dataSource:weakSelf didFinishUpdateWithError:result];
                    } else {
//                        L(result);
                        NSArray *tweets = result;
                        NSString *lastIdStr = tweets.lastObject[@"id_str"];
                        uint newTweetCount = tweets.count;
                        if (![latestIdStr isEqualToString:lastIdStr]) {
//                            [self.data insertObject:nil atIndex:0];
                        } else {
                            newTweetCount --;
                        }
                        for (int i=newTweetCount-1; i>=0; i--) {
                            NSDictionary *tweet = tweets[i];
                            HSUTableCellData *cellData = [[HSUTableCellData alloc] init];
                            cellData.rawData = tweet;
                            cellData.renderData = [@{@"data_type": @"Status"} mutableCopy];
                            [self.data insertObject:cellData atIndex:0];
                        }
                        [weakSelf saveCache];
                        [weakSelf.delegate dataSource:weakSelf didFinishUpdateWithError:nil];
                    }
                }
            });
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
