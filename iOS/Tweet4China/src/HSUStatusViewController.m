//
//  HSUStatusViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusViewController.h"
#import "HSUStatusDataSource.h"
#import "HSUMainStatusCell.h"

@interface HSUStatusViewController ()

@property (nonatomic, strong) NSDictionary *mainStatus;

@end

@implementation HSUStatusViewController

- (id)initWithStatus:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        self.mainStatus = status;
        self.dataSourceClass = [HSUStatusDataSource class];
        self.useRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    self.dataSource = [[self.dataSourceClass alloc] initWithDelegate:self status:self.mainStatus];
    self.dataSource.delegate = self;
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[HSUMainStatusCell class] forCellReuseIdentifier:kDataType_MainStatus];
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error
{
    [super dataSource:dataSource didFinishRefreshWithError:error];
}

@end
