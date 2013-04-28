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

#define padding_S 10

@implementation HSUStatusCell
{
    HSUStatusView *statusView;
    UIImageView *flagIV;
    HSUStatusActionView *actionV;
    
    BOOL retweeted, favorited;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        
        statusView = [[HSUStatusView alloc] initWithFrame:ccr(padding_S, padding_S, self.contentView.width-padding_S*4, 0)
                                                    style:HSUStatusViewStyle_Default];
        [self.contentView addSubview:statusView];
        
        flagIV = [[UIImageView alloc] init];
        [self.contentView addSubview:flagIV];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherCellSwiped:) name:kNotification_HSUStatusCell_OtherCellSwiped object:nil];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    statusView.frame = ccr(statusView.left, statusView.top, statusView.width, self.contentView.height-padding_S*2);
    
    [flagIV sizeToFit];
    flagIV.rightTop = ccp(self.contentView.width, 0);
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
    
    [statusView setupWithData:data];
    
    self.contentView.backgroundColor = kClearColor;
    statusView.alpha = 1;
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
            statusView.alpha = 1;
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
            statusView.alpha = 0;
            actionV.alpha = 1;
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HSUStatusCell_OtherCellSwiped object:self];
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
