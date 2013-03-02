//
//  HSUTabController.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "HSUTabController.h"
#import "HSUHomeViewController.h"
#import "HSUConnectViewController.h"
#import "HSUDiscoverViewController.h"
#import "HSUProfileViewController.h"
#import "HSUCommonTools.h"
#import "HSUNavitationBar.h"

@interface HSUTabController ()

@end

@implementation HSUTabController

- (id)init
{
    self = [super init];
    if (self) {
        UINavigationController *homeNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        homeNav.viewControllers = @[[[HSUHomeViewController alloc] init]];
        homeNav.tabBarItem.title = @"Home";
        [homeNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_home_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_home_default"]];
        
        UINavigationController *connectNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        connectNav.viewControllers = @[[[HSUConnectViewController alloc] init]];
        connectNav.tabBarItem.title = @"Connect";
        [connectNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_at_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_at_default"]];
        
        UINavigationController *discoverNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        discoverNav.viewControllers = @[[[HSUDiscoverViewController alloc] init]];
        discoverNav.tabBarItem.title = @"Discover";
        [discoverNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_hash_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_hash_default"]];
        
        UINavigationController *meNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        meNav.viewControllers = @[[[HSUProfileViewController alloc] init]];
        meNav.tabBarItem.title = @"Me";
        [meNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_profile_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_profile_default"]];
        
        self.viewControllers = @[homeNav, connectNav, discoverNav, meNav];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_tab_bar"]];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"bg_tab_bar_selected"]];
    self.tabBar.frame = CGRectMake(0, [HSUCommonTools winHeight]-kTabBarHeight, [HSUCommonTools winWidth], kTabBarHeight);
    ((UIView *)[self.view.subviews objectAtIndex:0]).frame = CGRectMake(0, 0, [HSUCommonTools winWidth], [HSUCommonTools winHeight]-kTabBarHeight);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
