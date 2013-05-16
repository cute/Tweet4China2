//
//  HSUDefaultStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/12/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUDefaultStatusCell.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+AFNetworking.h"
#import "FHSTwitterEngine.h"
#import "UIButton+WebCache.h"
#import "HSUStatusView.h"
#import "HSUStatusActionView.h"

@implementation HSUDefaultStatusCell
{
    UIImageView *flagIV;
    HSUStatusActionView *actionV;
    
    BOOL retweeted, favorited;
}

- (void)dealloc
{
    notification_remove_observer(self);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        flagIV = [[UIImageView alloc] init];
        [self.contentView addSubview:flagIV];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGesture];
        
        notification_add_observer(kNotification_HSUStatusCell_OtherCellSwiped, self, @selector(otherCellSwiped:));
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [flagIV sizeToFit];
    flagIV.rightTop = ccp(self.contentView.width, 0);
}

@end
