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
#import "HSURefreshControl.h"
#import "HSULoadMoreCell.h"
#import "HSUTabController.h"
#import "HSUComposeViewController.h"
#import "HSUStatusViewController.h"

@interface HSUBaseViewController ()

@end

@implementation HSUBaseViewController

#pragma mark - Liftstyle
- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUBaseDataSource class];
        self.useRefreshControl = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.dataSource) {
        self.dataSource = [self.dataSourceClass dataSourceWithDelegate:self useCache:YES];
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
    
    if (self.useRefreshControl) {
        HSURefreshControl *refreshControl = [[HSURefreshControl alloc] init];
        [refreshControl addTarget:self.dataSource action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [tableView addSubview:refreshControl];
        self.refreshControl = refreshControl;
    }
    
    self.navigationItem.rightBarButtonItems = [self _createRightBarButtonItems];
    if ([self.navigationController.viewControllers objectAtIndex:0] != self) {
        self.navigationItem.leftBarButtonItem = [self _createBackButton];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_texture"]];
    self.tableView.frame = self.view.bounds;
    
    NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HSUStatusCell_OtherCellSwiped object:self];
}

#pragma mark - TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndex:indexPath.row];
    Class cellClass = [self cellClassForDataType:data.dataType];
    return [cellClass heightForData:data];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndex:indexPath.row];
    if ([data.dataType isEqualToString:kDataType_Status]) {
        if ([data.renderData[@"mode"] isEqualToString:@"action"]) {
            return NO;
        }
        return YES;
    }
    if ([data.dataType isEqualToString:kDataType_LoadMore]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [self.dataSource dataAtIndex:indexPath.row];
    if ([data.dataType isEqualToString:kDataType_LoadMore]) {
        [self.dataSource loadMore];
    } else if ([data.dataType isEqualToString:kDataType_Status]) {
        HSUStatusViewController *statusVC = [[HSUStatusViewController alloc] initWithStatus:data.rawData];
        [self.navigationController pushViewController:statusVC animated:YES];
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

- (void)preprocessDataSourceForRender:(HSUBaseDataSource *)dataSource
{
    [dataSource addEventWithName:@"reply" target:self action:@selector(reply:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"retweet" target:self action:@selector(retweet:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"favorite" target:self action:@selector(favorite:) events:UIControlEventTouchUpInside];
    [dataSource addEventWithName:@"more" target:self action:@selector(more:) events:UIControlEventTouchUpInside];
}

#pragma mark - base view controller's methods
- (NSArray *)_createRightBarButtonItems
{
    // Search BarButtonItem
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"ic_title_search"] forState:UIControlStateNormal];
    [searchButton sizeToFit];
    searchButton.width *= 2.1;
    searchButton.showsTouchWhenHighlighted = YES;
    UIBarButtonItem *searchBarButton = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [searchButton setTapTarget:self action:@selector(_searchButtonTouched)];
    
    // Compose BarButtonItem
    UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [composeButton setImage:[UIImage imageNamed:@"ic_title_tweet"] forState:UIControlStateNormal];
    [composeButton sizeToFit];
    composeButton.width *= 1.42;
    composeButton.showsTouchWhenHighlighted = YES;
    [composeButton setTapTarget:self action:@selector(_composeButtonTouched)];
    
    UIBarButtonItem *composeBarButton = [[UIBarButtonItem alloc] initWithCustomView:composeButton];
    
    return @[composeBarButton, searchBarButton];
}

- (UIBarButtonItem *)_createBackButton
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"icn_nav_bar_back"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    backButton.width *= 1.6;
    backButton.showsTouchWhenHighlighted = YES;
    [backButton setTapTarget:self action:@selector(_backButtonTouched)];
    
    return [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)_backButtonTouched
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Actions
- (void)_composeButtonTouched
{
    HSUComposeViewController *composeViewController = [[HSUComposeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)_searchButtonTouched
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
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:nil destructiveButtonItem:nil otherButtonItems:nil];
    uint count = 0;
    
    NSArray *urls = rawData[@"entities"][@"urls"];
    if (urls && urls.count) { // has link
        RIButtonItem *tweetLinkItem = [RIButtonItem itemWithLabel:@"Tweet link"];
        tweetLinkItem.action = ^{
            if (urls.count == 1) {
                NSString *link = [urls objectAtIndex:0][@"expanded_url"];
                [self _composeWithText:S(@" %@", link)];
            } else {
                UIActionSheet *selectLinkActionSheet = [[UIActionSheet alloc] init];
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
                [selectLinkActionSheet addButtonItem:cancelItem];
                for (NSDictionary *urlDict in urls) {
                    NSString *displayUrl = urlDict[@"display_url"];
                    NSString *expendedUrl = urlDict[@"expanded_url"];
                    RIButtonItem *buttonItem = [RIButtonItem itemWithLabel:displayUrl];
                    buttonItem.action = ^{
                        [self _composeWithText:S(@" %@", expendedUrl)];
                    };
                    [selectLinkActionSheet addButtonItem:buttonItem];
                }
                [selectLinkActionSheet setCancelButtonIndex:urls.count];
                [selectLinkActionSheet showInView:self.view.window];
            }
        };
        [actionSheet addButtonItem:tweetLinkItem];
        count ++;
        
        RIButtonItem *copyLinkItem = [RIButtonItem itemWithLabel:@"Copy link"];
        copyLinkItem.action = ^{
            if (urls.count == 1) {
                NSString *link = [urls objectAtIndex:0][@"expanded_url"];
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = link;
            } else {
                UIActionSheet *selectLinkActionSheet = [[UIActionSheet alloc] init];
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
                [selectLinkActionSheet addButtonItem:cancelItem];
                for (NSDictionary *urlDict in urls) {
                    NSString *displayUrl = urlDict[@"display_url"];
                    NSString *expendedUrl = urlDict[@"expanded_url"];
                    RIButtonItem *buttonItem = [RIButtonItem itemWithLabel:displayUrl];
                    buttonItem.action = ^{
                        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                        pasteboard.string = expendedUrl;
                    };
                    [selectLinkActionSheet addButtonItem:buttonItem];
                }
                [selectLinkActionSheet setCancelButtonIndex:urls.count];
                [selectLinkActionSheet showInView:self.view.window];
            }
        };
        [actionSheet addButtonItem:copyLinkItem];
        count ++;
        
        RIButtonItem *mailLinkItem = [RIButtonItem itemWithLabel:@"Mail link"];
        mailLinkItem.action = ^{
            if (urls.count == 1) {
                NSString *link = [urls objectAtIndex:0][@"expanded_url"];
                NSString *subject = @"Link from Twitter";
                NSString *body = S(@"<a href=\"%@\">%@</a>", link, link);
                [HSUCommonTools sendMailWithSubject:subject body:body presentFromViewController:self];
            } else {
                UIActionSheet *selectLinkActionSheet = [[UIActionSheet alloc] init];
                RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
                [selectLinkActionSheet addButtonItem:cancelItem];
                for (NSDictionary *urlDict in urls) {
                    NSString *displayUrl = urlDict[@"display_url"];
                    NSString *expendedUrl = urlDict[@"expanded_url"];
                    RIButtonItem *buttonItem = [RIButtonItem itemWithLabel:displayUrl];
                    buttonItem.action = ^{
                        NSString *subject = @"Link from Twitter";
                        NSString *body = S(@"<a href=\"%@\">%@</a>", expendedUrl, displayUrl);
                        [HSUCommonTools sendMailWithSubject:subject body:body presentFromViewController:self];
                    };
                    [selectLinkActionSheet addButtonItem:buttonItem];
                }
                [selectLinkActionSheet setCancelButtonIndex:urls.count];
                [selectLinkActionSheet showInView:self.view.window];
            }
        };
        [actionSheet addButtonItem:mailLinkItem];
        count ++;
    }
    
    NSString *id_str = rawData[@"id_str"];
    NSString *link = S(@"https://twitter.com/rtfocus/status/%@", id_str);
    
    RIButtonItem *copyLinkToTweetItem = [RIButtonItem itemWithLabel:@"Copy link to Tweet"];
    copyLinkToTweetItem.action = ^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = link;
    };
    [actionSheet addButtonItem:copyLinkToTweetItem];
    count ++;
    
    NSString *name = rawData[@"user"][@"name"];
    NSString *screen_name = rawData[@"user"][@"screen_name"];
    NSString *profile_image_url_https = rawData[@"user"][@"profile_image_url_https"];
    NSString *text = rawData[@"text"];
    NSDate *createTime = [twe getDateFromTwitterCreatedAt:rawData[@"created_at"]];
    NSString *create_time = createTime.standardTwitterDisplay;
    
    RIButtonItem *mailTweetItem = [RIButtonItem itemWithLabel:@"Mail Tweet"];
    mailTweetItem.action = ^{
        NSURL *templatFileURL = [[NSBundle mainBundle] URLForResource:@"mail_tweet_template" withExtension:@"html"];
        // TODO: replace template placeholders with contents
        NSString *body = [[NSString alloc] initWithContentsOfURL:templatFileURL encoding:NSUTF8StringEncoding error:nil];;
        body = [body stringByReplacingOccurrencesOfString:@"${profile_image_url_https}" withString:profile_image_url_https];
        body = [body stringByReplacingOccurrencesOfString:@"${name}" withString:name];
        body = [body stringByReplacingOccurrencesOfString:@"${screen_name}" withString:screen_name];
        body = [body stringByReplacingOccurrencesOfString:@"${id_str}" withString:id_str];
        body = [body stringByReplacingOccurrencesOfString:@"${create_time}" withString:create_time];
        body = [body stringByReplacingOccurrencesOfString:@"${html}" withString:text];
        NSString *subject = @"Link from Twitter";
        [HSUCommonTools sendMailWithSubject:subject body:body presentFromViewController:self];
    };
    [actionSheet addButtonItem:mailTweetItem];
    count ++;
    
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    [actionSheet addButtonItem:cancelItem];
    
    [actionSheet setCancelButtonIndex:count];
    [actionSheet showInView:self.view.window];
}

- (void)_composeWithText:(NSString *)text
{
    HSUComposeViewController *composeVC = [[HSUComposeViewController alloc] init];
    composeVC.defaultText = text;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeVC];
    [self presentViewController:nav animated:YES completion:nil];
}


@end
