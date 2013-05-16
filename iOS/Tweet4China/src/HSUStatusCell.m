//
//  HSUStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUStatusCell.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+AFNetworking.h"
#import "FHSTwitterEngine.h"
#import "UIButton+WebCache.h"
#import "HSUStatusView.h"
#import "HSUStatusActionView.h"

@implementation HSUStatusCell
{
    UIImageView *flagIV;
    HSUStatusActionView *actionV;
    
    BOOL retweeted, favorited;
}

+ (HSUStatusViewStyle)statusStyle
{
    return HSUStatusViewStyle_Default;
}

- (void)dealloc
{
    notification_remove_observer(self);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        
        self.statusView = [[HSUStatusView alloc] initWithFrame:ccr(padding_S, padding_S, self.contentView.width-padding_S*4, 0)
                                                    style:[[self class] statusStyle]];
        [self.contentView addSubview:self.statusView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.statusView.frame = ccr(self.statusView.left, self.statusView.top, self.statusView.width, self.contentView.height-padding_S*2);
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    NSDictionary *rawData = data.rawData;
    retweeted = [rawData[@"retweeted"] boolValue];
    favorited = [rawData[@"favorited"] boolValue];
    
    if (retweeted && favorited) {
        flagIV.image = [UIImage imageNamed:@"ic_dogear_both"];
    } else if (retweeted) {
        flagIV.image = [UIImage imageNamed:@"ic_dogear_rt"];
    } else if (favorited) {
        flagIV.image = [UIImage imageNamed:@"ic_dogear_fave"];
    } else {
        flagIV.image = nil;
    }
    
    [self.statusView setupWithData:data];
    [self setupControl:self.statusView.avatarB forKey:@"touchAvatar"];
    
    self.contentView.backgroundColor = kClearColor;
    self.statusView.alpha = 1;
    self.data.renderData[@"mode"] = @"default";
    
    actionV.hidden = YES;
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    NSMutableDictionary *renderData = data.renderData;
    if (renderData) {
        if (renderData[@"height"]) {
            return [renderData[@"height"] floatValue];
        }
    }
    
    CGFloat height = [HSUStatusView heightForData:data constraintWidth:[HSUCommonTools winWidth] - 20 - padding_S*2] + padding_S * 2;
    renderData[@"height"] = @(height);
    return height;
}

- (void)cellSwiped:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self switchMode];
    }
}

- (void)switchMode {
    if (actionV) {
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.backgroundColor = kClearColor;
            self.statusView.alpha = 1;
            actionV.alpha = 0;
        } completion:^(BOOL finish){
            [actionV removeFromSuperview];
            actionV = nil;
        }];
        self.data.renderData[@"mode"] = @"default";
    } else {
        actionV = [[HSUStatusActionView alloc] initWithStatus:self.data.rawData style:HSUStatusActionViewStyle_Default];
        [self.contentView addSubview:actionV];
        UIColor *actionBGC = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_swipe_tile"]];
        actionV.backgroundColor = actionBGC;
        
        [self setupControl:actionV.replayB forKey:@"reply"];
        [self setupControl:actionV.retweetB forKey:@"retweet"];
        [self setupControl:actionV.favoriteB forKey:@"favorite"];
        [self setupControl:actionV.moreB forKey:@"more"];
        [self setupControl:actionV.deleteB forKey:@"delete"];
        
        actionV.frame = self.contentView.bounds;
        actionV.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.backgroundColor = bw(230);
            self.statusView.alpha = 0;
            actionV.alpha = 1;
        }];
        
        notification_post(kNotification_HSUStatusCell_OtherCellSwiped);
        self.data.renderData[@"mode"] = @"action";
    }
}

- (void)otherCellSwiped:(NSNotification *)notification {
    if (notification.object != self) {
        if (actionV && !actionV.hidden) {
            [self switchMode];
        }
    }
}

@end
