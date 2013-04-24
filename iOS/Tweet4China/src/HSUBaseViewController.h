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
@interface HSUBaseViewController : UIViewController <UITableViewDelegate, HSUBaseDataSourceDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) Class dataSourceClass;
@property (nonatomic, strong) HSUBaseDataSource *dataSource;
@property (nonatomic, weak) HSURefreshControl *refreshControl;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) BOOL showBackButton;
@property (nonatomic, assign) BOOL useRefreshControl;

- (Class)cellClassForDataType:(NSString *)dataType;

#pragma mark - Common actions
- (void)reply:(HSUTableCellData *)cellData;
- (void)retweet:(HSUTableCellData *)cellData;
- (void)favorite:(HSUTableCellData *)cellData;
- (void)more:(HSUTableCellData *)cellData;

@end
