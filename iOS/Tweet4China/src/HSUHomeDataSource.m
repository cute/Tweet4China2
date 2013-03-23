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
#import "HSULoadMoreCell.h"
#import "FHSTwitterEngine+Addition.h"

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
            id result = [twEngine getHomeTimelineSinceID:latestIdStr count:20];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([result isKindOfClass:[NSError class]]) {
                        [strongSelf.delegate dataSource:strongSelf didFinishUpdateWithError:result];
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
                            HSUTableCellData *cellData =
                                [[HSUTableCellData alloc] initWithRawData:tweets[i] dataType:kDataType_Status];
                            [strongSelf.data insertObject:cellData atIndex:0];
                        }
                        
                        HSUTableCellData *lastCellData = self.data.lastObject;
                        if (![lastCellData.dataType isEqualToString:kDataType_LoadMore]) {
                            HSUTableCellData *loadMoreCellData = [[HSUTableCellData alloc] init];
                            loadMoreCellData.rawData = @{@"status": @(kLoadMoreCellStatus_Done)};
                            loadMoreCellData.renderData = [@{@"data_type": kDataType_LoadMore} mutableCopy];
                            [strongSelf.data addObject:loadMoreCellData];
                        }
                        
                        [strongSelf saveCache];
                        [strongSelf.delegate dataSource:strongSelf didFinishUpdateWithError:nil];
                    }
                }
            });
        }
    });
}

- (void)loadMore
{
    [super loadMore];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            HSUTableCellData *lastStatusData = [self dataAtIndex:self.count-2];
            NSString *lastStatusId = lastStatusData.rawData[@"id_str"];
            id result =  [twEngine getHomeTimelineMaxId:lastStatusId count:20];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([result isKindOfClass:[NSError class]]) {
                        [self.data.lastObject renderData][@"status"] = kLoadMoreCellStatus_Error;
                        [strongSelf.delegate dataSource:strongSelf didFinishUpdateWithError:result];
                    } else {
                        for (NSDictionary *tweet in result) {
                            HSUTableCellData *cellData =
                                [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_Status];
                            [strongSelf.data insertObject:cellData atIndex:(self.count-2)];
                        }
                        
                        [strongSelf saveCache];
                        [self.data.lastObject renderData][@"status"] = kLoadMoreCellStatus_Done;
                        [strongSelf.delegate dataSource:strongSelf didFinishUpdateWithError:nil];
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
