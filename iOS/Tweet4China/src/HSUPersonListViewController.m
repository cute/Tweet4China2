//
//  HSUPersonListViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUPersonListViewController.h"
#import "HSUPersonListDataSource.h"

@implementation HSUPersonListViewController

- (instancetype)initWithDataSource:(HSUPersonListDataSource *)dataSource
{
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
        self.useRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.dataSource loadMore];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)preprocessDataSourceForRender:(HSUBaseDataSource *)dataSource
{
    [dataSource addEventWithName:@"follow" target:self action:@selector(follow:) events:UIControlEventTouchUpInside];
}

- (void)follow:(HSUTableCellData *)cellData
{
    NSString *screenName = cellData.rawData[@"screen_name"];
    cellData.renderData[@"sending_following_request"] = @(YES);
    [self.tableView reloadData];
    
    if ([cellData.rawData[@"following"] boolValue]) {
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE unfollowUser:screenName isID:NO];
            __weak __typeof(&*self)weakSelf = self;
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Unfollow failed"]) {
                        cellData.renderData[@"sending_following_request"] = @(NO);
                        NSMutableDictionary *rawData = cellData.rawData.mutableCopy;
                        rawData[@"following"] = @(NO);
                        cellData.rawData = rawData;
                        [strongSelf.tableView reloadData];
                    }
                }
            });
        });
    } else {
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE followUser:screenName isID:NO];
            __weak __typeof(&*self)weakSelf = self;
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Follow failed"]) {
                        cellData.renderData[@"sending_following_request"] = @(NO);
                        NSMutableDictionary *rawData = cellData.rawData.mutableCopy;
                        rawData[@"following"] = @(YES);
                        cellData.rawData = rawData;
                        [strongSelf.tableView reloadData];
                    }
                }
            });
        });
    }
}

@end
