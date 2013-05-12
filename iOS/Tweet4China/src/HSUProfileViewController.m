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
#import "HSUComposeViewController.h"
#import "HSUNavigationBarLight.h"

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
    if ([self.profile[@"blocked"] boolValue]) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *unblockItem = [RIButtonItem itemWithLabel:@"Unblock"];
        unblockItem.action = ^{
            dispatch_async(GCDBackgroundThread, ^{
                id result = [TWENGINE unblock:self.screenName];
                __weak __typeof(&*self)weakSelf = self;
                dispatch_sync(GCDMainThread, ^{
                    @autoreleasepool {
                        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                        if ([TWENGINE dealWithError:result errTitle:@"Unblock failed"]) {
                            NSMutableDictionary *profile = strongSelf.profile.mutableCopy;
                            profile[@"blocked"] = @(NO);
                            profile[@"following"] = @(NO);
                            strongSelf.profile = profile;
                            [strongSelf.profileView setupWithProfile:profile];
                        }
                    }
                });
            });
        };
        UIActionSheet *blockActionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:unblockItem otherButtonItems:nil, nil];
        [blockActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    } else if ([self.profile[@"following"] boolValue]) {
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
                    }
                    followButton.enabled = YES;
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
                    }
                    followButton.enabled = YES;
                }
            });
        });
    }
}

- (void)actionsButtonTouched
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:nil destructiveButtonItem:nil otherButtonItems:nil];
    uint count = 0;
    
    /*
    if ([self.profile[@"following"] boolValue]) {
        if ([self.profile[@"notifications"] boolValue]) {
            RIButtonItem *turnOffNotiItem = [RIButtonItem itemWithLabel:@"Turn off notifications"];
            turnOffNotiItem.action = ^{
                
            };
            [actionSheet addButtonItem:turnOffNotiItem];
        } else {
            RIButtonItem *turnOnNotiItem = [RIButtonItem itemWithLabel:@"Turn on notifications"];
            turnOnNotiItem.action = ^{
                
            };
            [actionSheet addButtonItem:turnOnNotiItem];
        }
        count ++;
        
        if ([self.profile[@"retweets"] boolValue]) {
            RIButtonItem *turnOffRetweetsItem = [RIButtonItem itemWithLabel:@"Turn off Retweets"];
            turnOffRetweetsItem.action = ^{
                
            };
            [actionSheet addButtonItem:turnOffRetweetsItem];
        } else {
            RIButtonItem *turnOnRetweetsItem = [RIButtonItem itemWithLabel:@"Turn on Retweets"];
            turnOnRetweetsItem.action = ^{
                
            };
            [actionSheet addButtonItem:turnOnRetweetsItem];
        }
        count ++;
    }
    */
    
    RIButtonItem *reportSpamItem = [RIButtonItem itemWithLabel:@"Report spam"];
    reportSpamItem.action = ^{
        dispatch_async(GCDBackgroundThread, ^{
            id result = [TWENGINE reportUserAsSpam:self.screenName isID:NO];
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    [TWENGINE dealWithError:result errTitle:@"Report spam failed"];
                }
            });
        });
    };
    [actionSheet addButtonItem:reportSpamItem];
    count ++;
    
    if ([self.profile[@"blocked"] boolValue]) {
        RIButtonItem *unblockItem = [RIButtonItem itemWithLabel:@"Unblock"];
        unblockItem.action = ^{
            dispatch_async(GCDBackgroundThread, ^{
                id result = [TWENGINE unblock:self.screenName];
                __weak __typeof(&*self)weakSelf = self;
                dispatch_sync(GCDMainThread, ^{
                    @autoreleasepool {
                        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                        if ([TWENGINE dealWithError:result errTitle:@"Unblock failed"]) {
                            NSMutableDictionary *profile = strongSelf.profile.mutableCopy;
                            profile[@"blocked"] = @(NO);
                            profile[@"following"] = @(NO);
                            strongSelf.profile = profile;
                            [strongSelf.profileView setupWithProfile:profile];
                        }
                    }
                });
            });
        };
        [actionSheet addButtonItem:unblockItem];
    } else {
        RIButtonItem *blockItem = [RIButtonItem itemWithLabel:@"Block"];
        blockItem.action = ^{
            dispatch_async(GCDBackgroundThread, ^{
                id result = [TWENGINE block:self.screenName];
                __weak __typeof(&*self)weakSelf = self;
                dispatch_sync(GCDMainThread, ^{
                    @autoreleasepool {
                        __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                        if ([TWENGINE dealWithError:result errTitle:@"Block failed"]) {
                            NSMutableDictionary *profile = strongSelf.profile.mutableCopy;
                            profile[@"blocked"] = @(YES);
                            profile[@"following"] = @(NO);
                            strongSelf.profile = profile;
                            [strongSelf.profileView setupWithProfile:profile];
                        }
                    }
                });
            });
        };
        [actionSheet addButtonItem:blockItem];
    }
    [actionSheet setDestructiveButtonIndex:count];
    count ++;
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    [actionSheet addButtonItem:cancelItem];
    [actionSheet setCancelButtonIndex:count];
    count ++;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)_composeButtonTouched
{
    HSUComposeViewController *composeVC = [[HSUComposeViewController alloc] init];
    if (![self.screenName isEqualToString:[TWENGINE myScreenName]]) {
        composeVC.defaultText = [NSString stringWithFormat:@"@%@ ", self.screenName];
        composeVC.defaultSelectedRange = NSMakeRange(0, composeVC.defaultText.length);
    }
    UINavigationController *nav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavigationBarLight class] toolbarClass:nil];
    nav.viewControllers = @[composeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
