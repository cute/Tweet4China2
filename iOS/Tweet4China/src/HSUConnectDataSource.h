//
//  HSUConnectDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

@interface HSUConnectDataSource : HSUBaseDataSource

+ (void)checkUnreadForViewController:(HSUBaseViewController *)viewController;

@end
