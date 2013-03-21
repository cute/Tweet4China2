//
//  HSUStatusCell.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSUBaseTableCell.h"

@class TTTAttributedLabel;
@interface HSUStatusCell : HSUBaseTableCell

@property (nonatomic, readonly) TTTAttributedLabel *contentLabel;

@end
