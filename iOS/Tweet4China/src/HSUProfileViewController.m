//
//  HSUProfileViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUProfileViewController.h"
#import "HSUProfileView.h"
#import "HSUProfileDataSource.h"
#import "HSUPersonListDataSource.h"
#import "HSUUserHomeDataSource.h"
#import "HSUTweetsViewController.h"
#import "HSUFollowersDataSource.h"
#import "HSUFollowingDataSource.h"
#import "HSUPersonListViewController.h"

@interface HSUProfileViewController ()

@property (nonatomic, strong) NSDictionary *profile;

@end

@implementation HSUProfileViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.useRefreshControl = NO;
        self.dataSourceClass = [HSUProfileDataSource class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *userScreenName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey][@"screen_name"];
    HSUProfileView *profileView = [[HSUProfileView alloc] initWithScreenName:userScreenName];
    self.tableView.tableHeaderView = profileView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_async(GCDBackgroundThread, ^{
        NSString *userScreenName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey][@"screen_name"];
        id result = [TWENGINE lookupUsers:@[userScreenName] areIDs:NO];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_sync(GCDMainThread, ^{
            @autoreleasepool {
                __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                if ([result isKindOfClass:[NSArray class]]) {
                    NSArray *profiles = result;
                    if (profiles.count) {
                        [(HSUProfileView *)strongSelf.tableView.tableHeaderView setupWithProfile:profiles[0]];
                        strongSelf.profile = profiles[0];
                    }
                }
            }
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndexPath:indexPath];
    if ([data.dataType isEqualToString:kDataType_NormalTitle]) {
        NSDictionary *rawData = data.rawData;
        NSString *screenName = rawData[@"user_screen_name"];
        if ([rawData[@"action"] isEqualToString:kAction_UserTimeline]) {
            HSUUserHomeDataSource *dataSource = [[HSUUserHomeDataSource alloc] init];
            dataSource.screenName = screenName;
            HSUTweetsViewController *detailVC = [[HSUTweetsViewController alloc] initWithDataSource:dataSource];
            dataSource.delegate = detailVC;
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Following]) {
            HSUPersonListDataSource *dataSource = [[HSUFollowingDataSource alloc] initWithScreenName:screenName];
            HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
            dataSource.delegate = detailVC;
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Followers]) {
            HSUPersonListDataSource *dataSource = [[HSUFollowersDataSource alloc] initWithScreenName:screenName];
            HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
            dataSource.delegate = detailVC;
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        }
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end
