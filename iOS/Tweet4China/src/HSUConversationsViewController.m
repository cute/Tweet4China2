//
//  HSUMessagesViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUConversationsViewController.h"
#import "HSUConversationsDataSource.h"

#define toolbar_height 44

@interface HSUConversationsViewController ()

@property (nonatomic, weak) UIToolbar *toolbar;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, weak) UIButton *editButton;

@end

@implementation HSUConversationsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUConversationsDataSource class];
        self.hideBackButton = YES;
        self.hideRightButtons = YES;
        self.useRefreshControl = NO;
        self.title = @"Messages";
    }
    return self;
}

- (void)viewDidLoad
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [super viewDidLoad];
    self.tableView.backgroundColor = kWhiteColor;
    
    // setup navigation bar
    self.navigationController.navigationBar.tintColor = bw(212);
    NSDictionary *attributes = @{UITextAttributeTextColor: bw(50),
                                 UITextAttributeTextShadowColor: kWhiteColor,
                                 UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 1)]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    // setup close button
    UIButton *closeButton = [[UIButton alloc] init];
    [closeButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_close"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    closeButton.width *= 1.4;
    closeButton.showsTouchWhenHighlighted = YES;
    [closeButton setTapTarget:self action:@selector(_closeButtonTouched)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UIButton *composeButton = [[UIButton alloc] init];
    [composeButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_compose_dm"] forState:UIControlStateNormal];
    [composeButton sizeToFit];
    composeButton.width *= 1.4;
    composeButton.showsTouchWhenHighlighted = YES;
    [composeButton setTapTarget:self action:@selector(_composeButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    
    // setup toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    toolbar.size = ccs(self.width, toolbar_height);
    [toolbar setBackgroundImage:[UIImage imageNamed:@"bg_tab_bar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIButton *editButton = [[UIButton alloc] init];
    self.editButton = editButton;
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    editButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [editButton sizeToFit];
    editButton.size = ccs(editButton.width + 20, editButton.height + 10);
    editButton.titleEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [editButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"btn_tool_bar_dark_segment_default"] stretchableImageFromCenter] forState:UIControlStateNormal];
    [editButton setBackgroundImage:[[UIImage imageNamed:@"btn_tool_bar_dark_segment_selected"] stretchableImageFromCenter] forState:UIControlStateHighlighted];
    [editButton setTapTarget:self action:@selector(_editButtonTouched)];
    UIBarButtonItem *editButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editButton];
    UIBarButtonItem *placeButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    toolbar.items = @[editButtonItem, placeButtonItem];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.dataSource refresh];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.toolbar.height = toolbar_height;
    self.toolbar.bottom = self.height;
    self.tableView.height = self.toolbar.top;
}

- (void)_closeButtonTouched
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_composeButtonTouched
{
    
}

- (void)_editButtonTouched
{
    self.editing = !self.editing;
    [self.tableView setEditing:self.editing animated:YES];
    if (self.editing) {
        [self.editButton setTitle:@"Done" forState:UIControlStateNormal];
    } else {
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

@end
