//
//  HSUBaseViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUBaseViewController.h"
#import "HSUTexturedView.h"
#import "HSUStatusCell.h"
#import "HSUStatusViewController.h"
#import "HSURefreshControl.h"
#import "HSULoadMoreCell.h"
#import "HSUTabController.h"
#import "HSUComposeViewController.h"

@interface HSUBaseViewController ()

@end

@implementation HSUBaseViewController

#pragma mark - Liftstyle
- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUBaseDataSource class];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(composeButtonTouched:) name:kHSUNotification_Compose object:nil];

    if (!self.dataSource) {
        self.dataSource = [self.dataSourceClass dataSource];
        self.dataSource.delegate = self;
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    // todo: rework
    [tableView registerClass:[HSUStatusCell class] forCellReuseIdentifier:kDataType_Status];
    [tableView registerClass:[HSULoadMoreCell class] forCellReuseIdentifier:kDataType_LoadMore];
    tableView.dataSource = self.dataSource;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.separatorColor = rgb(206, 206, 206);
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    HSURefreshControl *refreshControl = [[HSURefreshControl alloc] init];
    [refreshControl addTarget:self.dataSource action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *texture = [UIImage imageNamed:@"bg_texture"];
    UIView *background = [[HSUTexturedView alloc] initWithFrame:self.view.bounds texture:texture];
    [self.view insertSubview:background atIndex:0];
    
    self.tableView.frame = self.view.bounds;
}


#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndex:indexPath.row];
    Class cellClass = [self cellClassForDataType:data.dataType];
    return [cellClass heightForData:data];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndex:indexPath.row];
    if ([data.dataType isEqualToString:@"LoadMore"]) {
        [self.dataSource loadMore];
    }
}

- (Class)cellClassForDataType:(NSString *)dataType
{
    return NSClassFromString([NSString stringWithFormat:@"HSU%@Cell", dataType]);
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error);
    } else {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }

    [dataSource addEventWithName:@"reply" target:self action:@selector(reply:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"retweet" target:self action:@selector(retweet:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"favorite" target:self action:@selector(favorite:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"more" target:self action:@selector(more:) events:UIControlEventTouchUpInside];

    [((HSUTabController *)self.tabBarController) hideUnreadIndicatorOnTabBarItem:self.navigationController.tabBarItem];
    [HSUNetworkActivityIndicatorManager oneLess];
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishLoadMoreWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error);
    } else {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
    [HSUNetworkActivityIndicatorManager oneLess];
}

- (void)dataSourceDidFindUnread:(HSUBaseDataSource *)dataSource
{
    [((HSUTabController *)self.tabBarController) showUnreadIndicatorOnTabBarItem:self.navigationController.tabBarItem];
    [HSUNetworkActivityIndicatorManager oneLess];
}

#pragma mark - Actions
- (void)composeButtonTouched
{
    HSUComposeViewController *composeViewController = [[HSUComposeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)searchButtonTouched
{
    L(@"search button touched");
}

#pragma mark - Common actions
- (void)reply:(HSUTableCellData *)cellData {
    NSDictionary *rawData = cellData.rawData;
    NSString *screen_name = rawData[@"user"][@"screen_name"];
    NSString *id_str = rawData[@"id_str"];
    
    HSUComposeViewController *composeVC = [[HSUComposeViewController alloc] init];
    composeVC.defaultText = S(@"@%@ ", screen_name);
    composeVC.inReplyToStatusId = id_str;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)retweet:(HSUTableCellData *)cellData {
    NSDictionary *rawData = cellData.rawData;
    NSString *id_str = rawData[@"id_str"];
    
    dispatch_async(GCDBackgroundThread, ^{
        NSError *error = [twe retweet:id_str];
        [FHSTwitterEngine dealWithError:error errTitle:@"Reply tweet failed"];
    });
}

- (void)favorite:(HSUTableCellData *)cellData {
    NSDictionary *rawData = cellData.rawData;
    NSString *id_str = rawData[@"id_str"];
    BOOL favorited = [rawData[@"favorited"] boolValue];
    
    dispatch_async(GCDBackgroundThread, ^{
        NSError *error = [twe markTweet:id_str asFavorite:!favorited];
        [FHSTwitterEngine dealWithError:error errTitle:@"Favorite tweet failed"];
    });
}

- (void)more:(HSUTableCellData *)cellData {
    NSDictionary *rawData = cellData.rawData;
    NSString *id_str = rawData[@"id_str"];
    NSString *link = S(@"https://twitter.com/rtfocus/status/%@", id_str);
    
    RIButtonItem *copyLinkToTweetItem = [RIButtonItem itemWithLabel:@"Copy link to Tweet"];
    copyLinkToTweetItem.action = ^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = link;
    };
    
    RIButtonItem *mailTweetItem = [RIButtonItem itemWithLabel:@"Mail Tweet"];
    mailTweetItem.action = ^{
        NSString *body = S(@"<a href=\"%@\">%@</a><br><br>", link, link);
        NSString *subject = @"Link from Twitter";
        [HSUCommonTools sendMailWithSubject:subject body:body presentFromViewController:self];
    };
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:copyLinkToTweetItem, mailTweetItem, nil];
    [actionSheet showInView:self.view.window];
}


@end
