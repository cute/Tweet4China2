//
//  HSUStatusView.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/27/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HSUStatusViewStyle) {
    HSUStatusViewStyle_Default = 0,
    HSUStatusViewStyle_Gallery = 1,
    HSUStatusViewStyle_Light = 2,
};

@interface HSUStatusView : UIView <TTTAttributedLabelDelegate>

@property (nonatomic, strong) HSUTableCellData *data;
@property (nonatomic, assign) HSUStatusViewStyle style;

- (id)initWithFrame:(CGRect)frame style:(HSUStatusViewStyle)style;

- (void)setupWithData:(HSUTableCellData *)cellData;
+ (CGFloat)heightForData:(HSUTableCellData *)data constraintWidth:(CGFloat)constraintWidth;

@end
