//
//  HSUPersonListDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

@interface HSUPersonListDataSource : HSUBaseDataSource

@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *nextCursor;
@property (nonatomic, copy) NSString *prevCursor;

- (id)initWithScreenName:(NSString *)screenName;
- (id)fetchData;

@end
