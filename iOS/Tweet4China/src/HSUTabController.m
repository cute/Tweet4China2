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
        HSUHomeViewController *homeVC = [[HSUHomeViewController alloc] init];
        homeNav.viewControllers = @[homeVC];
        homeNav.tabBarItem.title = @"Home";
        [homeNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_home_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_home_default"]];
        [homeNav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -1)];

        UINavigationController *connectNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        HSUConnectViewController *connectVC = [[HSUConnectViewController alloc] init];
        connectNav.viewControllers = @[connectVC];
        connectNav.tabBarItem.title = @"Connect";
        [connectNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_at_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_at_default"]];
        [connectNav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -1)];
        
        UINavigationController *discoverNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        HSUDiscoverViewController *discoverVC = [[HSUDiscoverViewController alloc] init];
        discoverNav.viewControllers = @[discoverVC];
        discoverNav.tabBarItem.title = @"Discover";
        [discoverNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_hash_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_hash_default"]];
        [discoverNav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -1)];
        
        UINavigationController *meNav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavitationBar class] toolbarClass:nil];
        HSUProfileViewController *meVC = [[HSUProfileViewController alloc] init];
        meNav.viewControllers = @[meVC];
        meNav.tabBarItem.title = @"Me";
        [meNav.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"ic_tab_profile_selected"] withFinishedUnselectedImage:[UIImage imageNamed:@"ic_tab_profile_default"]];
        [meNav.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -1)];
        
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
        ((UIView *)[self.view.subviews objectAtIndex:0]).frame = CGRectMake(kIPadTabBarWidth, 0, kWinWidth, kWinHeight);
        
        UIImageView *tabBar = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_tab_bar"]];
        tabBar.frame = CGRectMake(0, 0, kIPadTabBarWidth, kWinHeight);
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
        self.tabBar.frame = CGRectMake(0, kWinHeight-kTabBarHeight, kWinWidth, kTabBarHeight);
        ((UIView *)[self.view.subviews objectAtIndex:0]).frame = CGRectMake(0, 0, kWinWidth, kWinHeight-kTabBarHeight);
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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

- (void)showUnreadIndicatorOnTabBarItem:(UITabBarItem *)tabBarItem
{
    uint idx = [self.tabBar.items indexOfObject:tabBarItem];
    if (idx == NSNotFound) {
        return;
    }
    
    UIImage *indicatorImage = [UIImage imageNamed:@"ic_glow"];
    UIImageView *indicator = [[UIImageView alloc] initWithImage:indicatorImage];
    uint curIdx = 0;
    for (UIView *subView in self.tabBar.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (idx == curIdx) {
                indicator.bottomCenter = ccp(subView.width/2, subView.height);
                [subView addSubview:indicator];
                break;
            } else {
                curIdx ++;
            }
        }
    }
}

- (void)hideUnreadIndicatorOnTabBarItem:(UITabBarItem *)tabBarItem
{
    uint idx = [self.tabBar.items indexOfObject:tabBarItem];
    if (idx == NSNotFound) {
        return;
    }
    
    uint curIdx = 0;
    for (UIView *subView in self.tabBar.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (idx == curIdx) {
                if ([subView.subviews.lastObject isKindOfClass:[UIImageView class]]) {
                    [subView.subviews.lastObject removeFromSuperview];
                }
                break;
            } else {
                curIdx ++;
            }
        }
    }
}

- (BOOL)hasUnreadIndicatorOnTabBarItem:(UITabBarItem *)tabBarItem
{
    uint idx = [self.tabBar.items indexOfObject:tabBarItem];
    if (idx == NSNotFound) {
        return NO;
    }
    
    uint curIdx = 0;
    for (UIView *subView in self.tabBar.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            if (idx == curIdx) {
                if ([subView.subviews.lastObject isKindOfClass:[UIImageView class]]) {
                    return YES;
                }
            } else {
                curIdx ++;
            }
        }
    }
    return NO;
}

@end
