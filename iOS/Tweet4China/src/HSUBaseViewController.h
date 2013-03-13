//
//  HSUBaseViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HSUBaseDataSource.h"
@interface HSUBaseViewController : UIViewController <UITableViewDelegate, HSUBaseDataSourceDelegate>

@property (nonatomic, assign) CGRect tableViewFrame;
@property (nonatomic, strong) Class dataSourceClass;
@property (nonatomic, strong) HSUBaseDataSource *dataSource;

- (Class)cellClassForDataType:(NSString *)dataType;

@end
