//
//  HSUMemtionViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUConnectViewController.h"
#import "HSUConnectDataSource.h"

@interface HSUConnectViewController ()

@end

@implementation HSUConnectViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.dataSourceClass = [HSUConnectDataSource class];
        [HSUConnectDataSource checkUnreadForViewController:self];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.dataSource.count == 0) {
        [self.refreshControl beginRefreshing];
        [self.dataSource refresh];
    }
}

#pragma mark - dataSource delegate
- (void)dataSourceDidFindUnread:(HSUBaseDataSource *)dataSource
{
    [super dataSourceDidFindUnread:dataSource];
}

#pragma mark - TableView delegate

@end
