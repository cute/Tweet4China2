//
//  HSUUserHomeDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTweetsDataSource.h"

@interface HSUUserHomeDataSource : HSUTweetsDataSource

@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *lastStatsuID;

@end
