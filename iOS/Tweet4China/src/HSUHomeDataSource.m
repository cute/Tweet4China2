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

- (void)checkUnread
{
    [super checkUnread];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        @autoreleasepool {
            NSString *latestIdStr = [strongSelf rawDataAtIndex:0][@"id_str"];
            if (!latestIdStr) {
                latestIdStr = @"1";
            }
            id result = [twEngine getHomeTimelineSinceID:latestIdStr count:1];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if (![result isKindOfClass:[NSError class]]) {
                        NSArray *tweets = result;
                        NSString *lastIdStr = tweets.lastObject[@"id_str"];
                        if (![latestIdStr isEqualToString:lastIdStr]) { // updated
                            [strongSelf.delegate dataSourceDidFindUnread:strongSelf];
                        }
                    }
                }
            });
        }
    });
}

- (void)refresh
{
    [super refresh];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
        @autoreleasepool {
            NSString *latestIdStr = [strongSelf rawDataAtIndex:0][@"id_str"];
            if (!latestIdStr) {
                latestIdStr = @"1";
            }
            id result = [twEngine getHomeTimelineSinceID:latestIdStr count:kRequestDataCount];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([result isKindOfClass:[NSError class]]) {
                        [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:result];
                    } else {
                        NSArray *tweets = result;
                        NSString *lastIdStr = tweets.lastObject[@"id_str"];
                        uint newTweetCount = tweets.count;
                        if ([latestIdStr isEqualToString:lastIdStr]) { // throw old tweets
                            newTweetCount --;
                            for (int i=newTweetCount-1; i>=0; i--) {
                                HSUTableCellData *cellData =
                                    [[HSUTableCellData alloc] initWithRawData:tweets[i] dataType:kDataType_Status];
                                [strongSelf.data insertObject:cellData atIndex:0];
                            }
                        } else {
                            [strongSelf.data removeAllObjects];
                            for (NSDictionary *tweet in tweets) {
                                HSUTableCellData *cellData =
                                    [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_Status];
                                [strongSelf.data addObject:cellData];
                            }
                        }
                        
                        HSUTableCellData *lastCellData = strongSelf.data.lastObject;
                        if (![lastCellData.dataType isEqualToString:kDataType_LoadMore]) {
                            HSUTableCellData *loadMoreCellData = [[HSUTableCellData alloc] init];
                            loadMoreCellData.rawData = @{@"status": @(kLoadMoreCellStatus_Done)};
                            loadMoreCellData.renderData = [@{@"data_type": kDataType_LoadMore} mutableCopy];
                            [strongSelf.data addObject:loadMoreCellData];
                        }
                        
                        [strongSelf saveCache];
                        [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:nil];
                        strongSelf.loading = NO;
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
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            HSUTableCellData *lastStatusData = [strongSelf dataAtIndex:strongSelf.count-2];
            NSString *lastStatusId = lastStatusData.rawData[@"id_str"];
            id result =  [twEngine getHomeTimelineMaxId:lastStatusId count:kRequestDataCount];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([result isKindOfClass:[NSError class]]) {
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Error);
                        [strongSelf.delegate dataSource:strongSelf didFinishLoadMoreWithError:result];
                    } else {
                        [result removeObjectAtIndex:0];
                        id loadMoreCellData = strongSelf.data.lastObject;
                        [strongSelf.data removeLastObject];
                        for (NSDictionary *tweet in result) {
                            HSUTableCellData *cellData =
                                [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_Status];
                            [strongSelf.data addObject:cellData];
                        }
                        [strongSelf.data addObject:loadMoreCellData];
                        
                        [strongSelf saveCache];
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Done);
                        [strongSelf.delegate dataSource:strongSelf didFinishLoadMoreWithError:nil];
                        strongSelf.loading = NO;
                    }
                }
            });
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isLoading) {
        HSUTableCellData *cellData = [self dataAtIndex:indexPath.row];
        if ([cellData.dataType isEqualToString:kDataType_LoadMore]) {
            cellData.renderData[@"status"] = @(kLoadMoreCellStatus_Loading);
            [self loadMore];
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

@end
