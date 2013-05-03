//
//  HSUPersonListViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseViewController.h"

@class HSUPersonListDataSource;
@interface HSUPersonListViewController : HSUBaseViewController

- (instancetype)initWithDataSource:(HSUPersonListDataSource *)dataSource;

@end
