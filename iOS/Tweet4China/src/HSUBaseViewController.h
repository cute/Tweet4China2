//
//  HSUBaseViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSUBaseDataSource.h"

@class HSURefreshControl;
@interface HSUBaseViewController : UIViewController <UITableViewDelegate, HSUBaseDataSourceDelegate>

@property (nonatomic, strong) Class dataSourceClass;
@property (nonatomic, strong) HSUBaseDataSource *dataSource;
@property (nonatomic, weak) HSURefreshControl *refreshControl;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, assign) BOOL useRefreshControl;

- (id)initWithDataSource:(HSUBaseDataSource *)dataSource;

- (Class)cellClassForDataType:(NSString *)dataType;

@end
