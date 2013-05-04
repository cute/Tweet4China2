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

@interface HSUProfileViewController () <HSUProfileViewDelegate>

@property (nonatomic, strong) NSDictionary *profile;

@end

@implementation HSUProfileViewController

- (id)init
{
    return [self initWithScreenName:[[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey][@"screen_name"]];
}

- (id)initWithScreenName:(NSString *)screenName
{
    self = [super init];
    if (self) {
        self.screenName = screenName;
        self.useRefreshControl = NO;
        self.dataSource = [[HSUProfileDataSource alloc] initWithScreenName:screenName];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HSUProfileView *profileView = [[HSUProfileView alloc] initWithScreenName:self.screenName delegate:self];
    self.tableView.tableHeaderView = profileView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    dispatch_async(GCDBackgroundThread, ^{
        id result = [TWENGINE lookupUsers:@[self.screenName] areIDs:NO];
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
        if ([rawData[@"action"] isEqualToString:kAction_UserTimeline]) {
            HSUUserHomeDataSource *dataSource = [[HSUUserHomeDataSource alloc] init];
            dataSource.screenName = self.screenName;
            HSUTweetsViewController *detailVC = [[HSUTweetsViewController alloc] initWithDataSource:dataSource];
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Following]) {
            HSUPersonListDataSource *dataSource = [[HSUFollowingDataSource alloc] initWithScreenName:self.screenName];
            HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Followers]) {
            HSUPersonListDataSource *dataSource = [[HSUFollowersDataSource alloc] initWithScreenName:self.screenName];
            HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
            [self.navigationController pushViewController:detailVC animated:YES];
            return;
        }
    }
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tweetsButtonTouched
{
    HSUUserHomeDataSource *dataSource = [[HSUUserHomeDataSource alloc] init];
    dataSource.screenName = self.screenName;
    HSUTweetsViewController *detailVC = [[HSUTweetsViewController alloc] initWithDataSource:dataSource];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)followingButtonTouched
{
    HSUPersonListDataSource *dataSource = [[HSUFollowingDataSource alloc] initWithScreenName:self.screenName];
    HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)followersButtonTouched
{
    HSUPersonListDataSource *dataSource = [[HSUFollowersDataSource alloc] initWithScreenName:self.screenName];
    HSUPersonListViewController *detailVC = [[HSUPersonListViewController alloc] initWithDataSource:dataSource];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
