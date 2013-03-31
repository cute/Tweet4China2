//
//  HSUHomeDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

@protocol TTTAttributedLabelDelegate;
@interface HSUHomeDataSource : HSUBaseDataSource

@property (nonatomic, weak) id<TTTAttributedLabelDelegate> attributeLabelDelegate;

@end
