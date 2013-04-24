//
//  HSUConnectDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUConnectDataSource.h"
#import "HSULoadMoreCell.h"

@implementation HSUConnectDataSource

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
            id result = [TWENGINE getMentionsTimelineWithCount:1 sinceID:latestIdStr maxID:nil];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if (![result isKindOfClass:[NSError class]]) {
                        NSArray *tweets = result;
                        NSString *lastIdStr = tweets.lastObject[@"id_str"];
                        if (![latestIdStr isEqualToString:lastIdStr]) { // updated
                            [strongSelf.delegate dataSourceDidFindUnread:strongSelf];
                        }
                    } else {
                        
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
            id result = [TWENGINE getMentionsTimelineWithCount:[self.class requestDataCount] sinceID:latestIdStr maxID:nil];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Load failed"]) {
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
                            loadMoreCellData.dataType = kDataType_LoadMore;
                            [strongSelf.data addObject:loadMoreCellData];
                        }
                        
                        [strongSelf saveCache];
                        [strongSelf.delegate preprocessDataSourceForRender:self];
                        [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:nil];
                        strongSelf.loadingCount --;
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
            id result = [TWENGINE getMentionsTimelineWithCount:[self.class requestDataCount] sinceID:nil maxID:lastStatusId];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Load failed"]) {
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
                        [strongSelf.delegate preprocessDataSourceForRender:self];
                        [strongSelf.delegate dataSource:strongSelf didFinishLoadMoreWithError:nil];
                    } else {
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Error);
                    }
                    strongSelf.loadingCount --;
                }
            });
        }
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.loadingCount && self.count > 1) {
        HSUTableCellData *cellData = [self dataAtIndex:indexPath.row];
        if ([cellData.dataType isEqualToString:kDataType_LoadMore]) {
            cellData.renderData[@"status"] = @(kLoadMoreCellStatus_Loading);
            [self loadMore];
        }
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

+ (NSUInteger)requestDataCount
{
    return 20;
}

@end
