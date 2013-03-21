//
//  HSUTabController.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTabController.h"
#import "HSUHomeViewController.h"
#import "HSUConnectViewController.h"
#import "HSUDiscoverViewController.h"
#import "HSUProfileViewController.h"
#import "HSUCommonTools.h"
#import "HSUNavitationBar.h"

@interface HSUTabController ()

@property (nonatomic, retain) NSArray *tabBarItemsData;
@property (nonatomic, retain) NSMutableArray *tabBarItems;
@property (nonatomic, weak) UIButton *selectedTabBarItem;

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
    
    
    self.tabBarItemsData = @[@{@"title": @"Home", @"imageName": @"home"},
                             @{@"title": @"Connect", @"imageName": @"connect"},
                             @{@"title": @"Discover", @"imageName": @"discover"},
                             @{@"title": @"Me", @"imageName": @"me"}];
    
    if ([HSUCommonTools isIPad]) {
        [self.tabBar setHidden:YES];
        ((UIView *)[self.view.subviews objectAtIndex:0]).frame = CGRectMake(kIPadTabBarWidth, 0, [HSUCommonTools winWidth], [HSUCommonTools winHeight]);
        
        UIImageView *tabBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_tab_bar"]];
        tabBar.frame = CGRectMake(0, 0, kIPadTabBarWidth, [HSUCommonTools winHeight]);
        tabBar.userInteractionEnabled = YES;
        [self.view addSubview:tabBar];
        
        CGFloat paddingTop = 24;
        CGFloat buttonItemHeight = 87;
        
        self.tabBarItems = [@[] mutableCopy];
        for (NSDictionary *tabBarItemData in self.tabBarItemsData) {
            NSString *title = tabBarItemData[@"title"];
            NSString *imageName = tabBarItemData[@"imageName"];
            
            UIButton *tabBarItem = [UIButton buttonWithType:UIButtonTypeCustom];
            tabBarItem.tag = [self.tabBarItemsData indexOfObject:tabBarItemData];
            [tabBarItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icn_tab_%@_default", imageName]] forState:UIControlStateNormal];
            [tabBarItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icn_tab_%@_selected", imageName]] forState:UIControlStateHighlighted];
            tabBarItem.frame = CGRectMake(0, buttonItemHeight*[self.tabBarItemsData indexOfObject:tabBarItemData], kIPadTabBarWidth, buttonItemHeight);
            tabBarItem.imageEdgeInsets = UIEdgeInsetsMake(paddingTop, 0, 0, 0);
            
            UILabel *titleLabel = [[UILabel alloc] init];
            titleLabel.text = title;
            titleLabel.font = [UIFont systemFontOfSize:10];
            titleLabel.backgroundColor = kClearColor;
            titleLabel.textColor = kWhiteColor;
            [titleLabel sizeToFit];
            titleLabel.center = tabBarItem.center;
            titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, buttonItemHeight-titleLabel.bounds.size.height+5, titleLabel.bounds.size.width, titleLabel.bounds.size.height);
            [tabBarItem addSubview:titleLabel];
            
            [tabBar addSubview:tabBarItem];
            
            if (tabBarItem.tag == 0) {
                [tabBarItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"icn_tab_%@_selected", imageName]] forState:UIControlStateNormal];
            }
            [self.tabBarItems addObject:tabBarItem];
            
            [tabBarItem addTarget:self action:@selector(iPadTabBarItemTouched:) forControlEvents:UIControlEventTouchDown];
        }
    } else {
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"bg_tab_bar"]];
        [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"bg_tab_bar_selected"]];
        self.tabBar.frame = CGRectMake(0, [HSUCommonTools winHeight]-kTabBarHeight, [HSUCommonTools winWidth], kTabBarHeight);
        ((UIView *)[self.view.subviews objectAtIndex:0]).frame = CGRectMake(0, 0, [HSUCommonTools winWidth], [HSUCommonTools winHeight]-kTabBarHeight);
    }
}

- (void)iPadTabBarItemTouched:(id)sender
{
    for (UIButton *tabBarItem in self.tabBarItems) {
        NSString *imageName = self.tabBarItemsData[tabBarItem.tag][@"imageName"];
        if (tabBarItem == sender) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icn_tab_%@_selected", imageName]];
            [tabBarItem setImage:image forState:UIControlStateNormal];
        } else {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"icn_tab_%@_default", imageName]];
            [tabBarItem setImage:image forState:UIControlStateNormal];
        }
    }
    self.selectedTabBarItem = sender;
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
