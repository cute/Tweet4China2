//
//  HSUTweetsDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTweetsDataSource.h"

@implementation HSUTweetsDataSource

- (void)refresh
{
    [super refresh];
    
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            id result = [self fetchRefreshData];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Load failed"]) {
                        NSArray *tweets = result;
                        if (tweets.count) {
                            for (int i=tweets.count-1; i>=0; i--) {
                                HSUTableCellData *cellData =
                                [[HSUTableCellData alloc] initWithRawData:tweets[i] dataType:kDataType_DefaultStatus];
                                [strongSelf.data insertObject:cellData atIndex:0];
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
                        }
                        [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:nil];
                        strongSelf.loadingCount --;
                    } else {
                        [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:result];
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
            id result = [self fetchMoreData];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Load failed"]) {
                        [result removeObjectAtIndex:0];
                        id loadMoreCellData = strongSelf.data.lastObject;
                        [strongSelf.data removeLastObject];
                        for (NSDictionary *tweet in result) {
                            HSUTableCellData *cellData =
                            [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_DefaultStatus];
                            [strongSelf.data addObject:cellData];
                        }
                        [strongSelf.data addObject:loadMoreCellData];
                        
                        [strongSelf saveCache];
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Done);
                        [strongSelf.delegate preprocessDataSourceForRender:self];
                    } else {
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Error);
                    }
                    [strongSelf.delegate dataSource:strongSelf didFinishLoadMoreWithError:nil];
                    strongSelf.loadingCount --;
                }
            });
        }
    });
}

- (NSUInteger)requestCount
{
    if ([Reachability reachabilityForInternetConnection].isReachableViaWiFi) {
        return kRequestDataCountViaWifi;
    } else {
        return kRequestDataCountViaWWAN;
    }
}

- (id)fetchRefreshData
{
    return nil;
}

- (id)fetchMoreData
{
    return nil;
}

@end
