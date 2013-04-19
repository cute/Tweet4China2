//
//  HSUStatusDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/18/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

@interface HSUStatusDataSource : HSUBaseDataSource

- (id)initWithDelegate:(id<HSUBaseDataSourceDelegate>)delegate status:(NSDictionary *)status;

@end
