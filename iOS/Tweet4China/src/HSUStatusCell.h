//
//  HSUStatusCell.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSUBaseTableCell.h"
#import "HSUStatusView.h"

#define padding_S 10

#define kNotification_HSUStatusCell_OtherCellSwiped @"HSUStatusCell_OtherCellSwiped"

@class HSUStatusView;
@interface HSUStatusCell : HSUBaseTableCell

@property (nonatomic, strong) HSUStatusView *statusView;

+ (HSUStatusViewStyle)statusStyle;

@end
