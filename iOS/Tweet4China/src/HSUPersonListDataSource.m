//
//  HSUPersonListDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUPersonListDataSource.h"

@implementation HSUPersonListDataSource

- (id)initWithScreenName:(NSString *)screenName
{
    self = [super init];
    if (self) {
        self.screenName = screenName;
    }
    return self;
}

- (id)fetchData
{
    return nil;
}

- (void)loadMore
{
    [super loadMore];
    
    dispatch_async(GCDBackgroundThread, ^{
        id result = [self fetchData];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_sync(GCDMainThread, ^{
            @autoreleasepool {
                __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                if ([TWENGINE dealWithError:result errTitle:@"Load followers failed"]) {
                    NSDictionary *dict = result;
                    strongSelf.nextCursor = dict[@"next_cursor_str"];
                    strongSelf.prevCursor = dict[@"previous_cursor_str"];
                    NSArray *users = dict[@"users"];
                    if (users.count) {
                        HSUTableCellData *loadMoreCellData = strongSelf.data.lastObject;
                        [strongSelf.data removeLastObject];
                        for (NSDictionary *tweet in users) {
                            HSUTableCellData *cellData =
                            [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_Person];
                            [strongSelf.data addObject:cellData];
                        }
                        if (!loadMoreCellData) {
                            loadMoreCellData = [[HSUTableCellData alloc] init];
                            loadMoreCellData.rawData = @{@"status": @(kLoadMoreCellStatus_Done)};
                            loadMoreCellData.dataType = kDataType_LoadMore;
                        }
                        [strongSelf.data addObject:loadMoreCellData];
                        
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Done);
                        [strongSelf.delegate preprocessDataSourceForRender:self];
                    } else {
                        [strongSelf.data.lastObject renderData][@"status"] = @(kLoadMoreCellStatus_Error);
                    }
                    [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:nil];
                    strongSelf.loadingCount --;
                }
            }
        });
    });
}

@end
