//
//  HSUTweetsDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

@interface HSUTweetsDataSource : HSUBaseDataSource

@property (nonatomic, copy) NSString *screenName;

- (id)fetchRefreshData;
- (id)fetchMoreData;

@end
