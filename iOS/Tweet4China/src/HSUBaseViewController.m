//
//  HSUBaseViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseViewController.h"
#import "HSUTexturedView.h"
#import "HSUStatusCell.h"
#import "HSUBaseDataSource.h"
#import "HSUStatusViewController.h"
#import "HSURefreshControl.h"
#import "HSUBaseDataSource.h"
#import "HSUTableCellData.h"
#import <QuartzCore/QuartzCore.h>

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
    
    if (!self.dataSource) {
        self.dataSource = [self.dataSourceClass dataSource];
        self.dataSource.delegate = self;
    }
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [tableView registerClass:[HSUStatusCell class] forCellReuseIdentifier:@"Status"];
    tableView.dataSource = self.dataSource;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.separatorColor = uic(206, 206, 206, 1);
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
    
    self.tableView.frame = self.view.bounds;//ccr(10, 10, self.view.bounds.size.width-20, self.view.bounds.size.height-10);
//    self.tableView.scrollIndicatorInsets = edi(-10, -10, 0, -10);
//    self.tableView.clipsToBounds = NO;
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

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishUpdateWithError:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error);
    } else {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }
    [HSUNetworkActivityIndicatorManager oneLess];
}

#pragma mark - Actions

@end
