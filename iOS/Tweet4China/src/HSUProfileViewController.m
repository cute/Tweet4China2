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

@property (nonatomic, strong) HSUProfileView *profileView;

@end

@implementation HSUProfileViewController

- (id)init
{
    return [self initWithScreenName:MyScreenName];
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
    if (self.profile) {
        [profileView setupWithProfile:self.profile];
    }
    self.tableView.tableHeaderView = profileView;
    self.profileView = profileView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.profile) {
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE lookupUsers:@[self.screenName] areIDs:NO];
            __weak __typeof(&*self)weakSelf = self;
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([result isKindOfClass:[NSArray class]]) {
                        NSArray *profiles = result;
                        if (profiles.count) {
                            [strongSelf.profileView setupWithProfile:profiles[0]];
                            strongSelf.profile = profiles[0];
                        }
                    }
                }
            });
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndexPath:indexPath];
    if ([data.dataType isEqualToString:kDataType_NormalTitle]) {
        NSDictionary *rawData = data.rawData;
        if ([rawData[@"action"] isEqualToString:kAction_UserTimeline]) {
            [self tweetsButtonTouched];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Following]) {
            [self followingButtonTouched];
            return;
        } else if ([rawData[@"action"] isEqualToString:kAction_Followers]) {
            [self followersButtonTouched];
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

- (void)followButtonTouched:(UIButton *)followButton
{
    followButton.enabled = NO;
    if ([self.profile[@"following"] boolValue]) {
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE unfollowUser:self.screenName isID:NO];
            __weak __typeof(&*self)weakSelf = self;
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Unfollow failed"]) {
                        NSMutableDictionary *profile = strongSelf.profile.mutableCopy;
                        profile[@"following"] = @(NO);
                        strongSelf.profile = profile;
                        [strongSelf.profileView setupWithProfile:profile];
                        followButton.enabled = YES;
                    }
                }
            });
        });
    } else {
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE followUser:self.screenName isID:NO];
            __weak __typeof(&*self)weakSelf = self;
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                    if ([TWENGINE dealWithError:result errTitle:@"Follow failed"]) {
                        NSMutableDictionary *profile = strongSelf.profile.mutableCopy;
                        profile[@"following"] = @(YES);
                        strongSelf.profile = profile;
                        [strongSelf.profileView setupWithProfile:profile];
                        followButton.enabled = YES;
                    }
                }
            });
        });
    }
}

@end
