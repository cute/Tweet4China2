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
        
        UINavigationController *connectNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        connectNav.viewControllers = @[[[HSUConnectViewController alloc] init]];
        connectNav.tabBarItem.title = @"Connect";
        
        UINavigationController *discoverNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        discoverNav.viewControllers = @[[[HSUDiscoverViewController alloc] init]];
        discoverNav.tabBarItem.title = @"Discover";
        
        UINavigationController *meNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        meNav.viewControllers = @[[[HSUProfileViewController alloc] init]];
        meNav.tabBarItem.title = @"Me";
        
        self.viewControllers = @[homeNav, connectNav, discoverNav, meNav];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
