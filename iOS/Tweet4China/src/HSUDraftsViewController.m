//
//  HSUDraftsViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUDraftsViewController.h"
#import "HSUDraftsDataSource.h"
#import "HSUComposeViewController.h"

#define toolbar_height 44

@interface HSUDraftsViewController ()

@property (nonatomic, weak) UIToolbar *toolbar;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, weak) UIButton *editButton;

@end

@implementation HSUDraftsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUDraftsDataSource class];
        self.hideBackButton = YES;
        self.hideRightButtons = YES;
        self.useRefreshControl = NO;
        self.title = @"Drafts";
    }
    return self;
}

- (void)viewDidLoad
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [super viewDidLoad];
    
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
    
    UIButton *sendButton = [[UIButton alloc] init];
    [sendButton setTitle:@"Send All" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [sendButton sizeToFit];
    sendButton.size = ccs(sendButton.width + 20, sendButton.height + 10);
    [sendButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[[UIImage imageNamed:@"btn_tool_bar_dark_segment_default"] stretchableImageFromCenter] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[[UIImage imageNamed:@"btn_tool_bar_dark_segment_selected"] stretchableImageFromCenter] forState:UIControlStateHighlighted];
    [sendButton setTapTarget:self action:@selector(_sendButtonTouched)];
    UIBarButtonItem *sendAllButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    toolbar.items = @[editButtonItem, placeButtonItem, sendAllButtonItem];
    placeButtonItem.width = 200;
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

- (void)_sendButtonTouched
{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *cellData = [self.dataSource dataAtIndexPath:indexPath];
    if ([cellData.dataType isEqualToString:kDataType_Draft]) {
        UINavigationController *nav = DEF_NavitationController_Light;
        HSUComposeViewController *composeVC = [[HSUComposeViewController alloc] init];
        composeVC.defaultTitle = cellData.rawData[@"title"];
        composeVC.defaultText = cellData.rawData[@"status"];
        composeVC.inReplyToStatusId = cellData.rawData[kTwitter_Parameter_Key_Reply_ID];
        nav.viewControllers = @[composeVC];
        [self dismissViewControllerAnimated:YES completion:^{
            [[HSUAppDelegate shared].tabController presentViewController:nav animated:YES completion:nil];
        }];
        return;
    }
    
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
}

// support editing

@end
