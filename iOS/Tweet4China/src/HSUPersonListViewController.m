//
//  HSUPersonListViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUPersonListViewController.h"
#import "HSUPersonListDataSource.h"
#import "HSUProfileViewController.h"

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
    HSUTableCellData *data = [self.dataSource dataAtIndexPath:indexPath];
    if ([data.dataType isEqualToString:kDataType_Person]) {
        [self touchAvatar:data];
        return;
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)preprocessDataSourceForRender:(HSUBaseDataSource *)dataSource
{
    [dataSource addEventWithName:@"follow" target:self action:@selector(follow:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"touchAvatar" target:self action:@selector(touchAvatar:) events:UIControlEventTouchUpInside];
}

- (void)touchAvatar:(HSUTableCellData *)cellData
{
    NSString *screenName = cellData.rawData[@"screen_name"];
    HSUProfileViewController *profileVC = [[HSUProfileViewController alloc] initWithScreenName:screenName];
    profileVC.profile = cellData.rawData;
    [self.navigationController pushViewController:profileVC animated:YES];
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
