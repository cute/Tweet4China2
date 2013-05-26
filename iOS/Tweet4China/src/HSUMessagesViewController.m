//
//  HSUMessageViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUMessagesViewController.h"
#import "HSUMessagesDataSource.h"

@interface HSUMessagesViewController ()

@end

@implementation HSUMessagesViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hideBackButton = YES;
        self.hideRightButtons = YES;
        self.useRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [super viewDidLoad];
    self.tableView.backgroundColor = kWhiteColor;
    
    // setup navigation bar
    self.navigationController.navigationBar.tintColor = bw(212);
    NSDictionary *attributes = @{UITextAttributeTextColor: bw(30),
                                 UITextAttributeTextShadowColor: kWhiteColor,
                                 UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 1)]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    // setup navgation bar buttons
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_back"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    backButton.width *= 1.4;
    backButton.showsTouchWhenHighlighted = YES;
    [backButton setTapTarget:self action:@selector(_backButtonTouched)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *actionsButton = [[UIButton alloc] init];
    [actionsButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_actions"] forState:UIControlStateNormal];
    [actionsButton sizeToFit];
    actionsButton.width *= 1.4;
    actionsButton.showsTouchWhenHighlighted = YES;
    [actionsButton setTapTarget:self action:@selector(_actionsButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:actionsButton];
}

@end
