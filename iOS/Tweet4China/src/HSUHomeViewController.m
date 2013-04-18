//
//  HSUHomeViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUHomeViewController.h"
#import "HSUHomeDataSource.h"
#import "TTTAttributedLabel.h"
#import "UIActionSheet+Blocks.h"
#import "HSURefreshControl.h"
#import "HSUTabController.h"

@interface HSUHomeViewController () <TTTAttributedLabelDelegate>

@end

@implementation HSUHomeViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUHomeDataSource class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (HSUTableCellData *cellData in self.dataSource.allData) {
        cellData.renderData[@"attributed_label_delegate"] = self;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [(HSUHomeDataSource *)self.dataSource authenticate];
    
    if (self.dataSource.count == 0) {
        [self.refreshControl beginRefreshing];
        [self.dataSource refresh];
    } else {
//        return;
        if (![((HSUTabController *)self.navigationController.tabBarController) hasUnreadIndicatorOnTabBarItem:self.navigationController.tabBarItem]) {
            [self.dataSource checkUnread];
        }
    }
}

#pragma mark - dataSource delegate
- (void)dataSourceDidFindUnread:(HSUBaseDataSource *)dataSource
{
    [super dataSourceDidFindUnread:dataSource];
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error
{
    [super dataSource:dataSource didFinishRefreshWithError:error];
    
    for (HSUTableCellData *cellData in self.dataSource.allData) {
        cellData.renderData[@"attributed_label_delegate"] = self;
    }
}

#pragma mark - TableView delegate

#pragma mark - attributtedLabel delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    RIButtonItem *tweetLinkItem = [RIButtonItem itemWithLabel:@"Tweet Link"];
    tweetLinkItem.action = ^{
        
    };
    RIButtonItem *copyLinkItem = [RIButtonItem itemWithLabel:@"Copy Link"];
    copyLinkItem.action = ^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = url.absoluteString;
    };
    RIButtonItem *mailLinkItem = [RIButtonItem itemWithLabel:@"Mail Link"];
    mailLinkItem.action = ^{
        NSString *body = S(@"<a href=\"%@\">%@</a><br><br>", url.absoluteString, url.absoluteString);
        NSString *subject = @"Link from Twitter";
        [HSUCommonTools sendMailWithSubject:subject body:body presentFromViewController:self];
    };
    RIButtonItem *openInSafariItem = [RIButtonItem itemWithLabel:@"Open in Safari"];
    openInSafariItem.action = ^{
        [[UIApplication sharedApplication] openURL:url];
    };
    UIActionSheet *linkActionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:tweetLinkItem, copyLinkItem, mailLinkItem, openInSafariItem, nil];
    [linkActionSheet showInView:self.view.window];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didReleaseLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

@end
