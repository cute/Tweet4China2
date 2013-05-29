//
//  HSUMessageCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/22/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUMessageCell.h"
#import "TTTAttributedLabel.h"
#import "UIButton+WebCache.h"
#import <QuartzCore/QuartzCore.h>

@interface HSUMessageCell ()

@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIImageView *contentBackground;
@property (nonatomic, weak) TTTAttributedLabel *contentLabel;
@property (nonatomic, weak) UIButton *avatarButton;
@property (nonatomic, weak) UIButton *retryButton;

@property (nonatomic, assign, getter = isMyself) BOOL myself;

@end

@implementation HSUMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:timeLabel];
        self.timeLabel = timeLabel;
        timeLabel.backgroundColor = kClearColor;
        timeLabel.textColor = kGrayColor;
        timeLabel.font = [UIFont systemFontOfSize:10];
        
        UIImageView *contentBackground = [[UIImageView alloc] init];
        [self.contentView addSubview:contentBackground];
        self.contentBackground = contentBackground;
        
        TTTAttributedLabel *contentLabel = [[TTTAttributedLabel alloc] init];
        [self.contentView addSubview:contentLabel];
        self.contentLabel = contentLabel;
        contentLabel.textColor = rgb(38, 38, 38);
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.backgroundColor = kClearColor;
        contentLabel.highlightedTextColor = kWhiteColor;
        contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        contentLabel.numberOfLines = 0;
        contentLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                                        (NSString *)kCTForegroundColorAttributeName: (id)cgrgb(30, 98, 164)};
        contentLabel.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgrgb(215, 230, 242),
                                              (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
        contentLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        contentLabel.lineHeightMultiple = 1 + 4.0/14;
        
        UIButton *avatarButton = [[UIButton alloc] init];
        [self.contentView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        avatarButton.layer.cornerRadius = 5;
        avatarButton.layer.masksToBounds = YES;
        avatarButton.size = ccs(50, 50);
        
        UIButton *retryButton = [[UIButton alloc] init];
        [self.contentView addSubview:retryButton];
        self.retryButton = retryButton;
        [retryButton setImage:[UIImage imageNamed:@"error-bubble"] forState:UIControlStateNormal];
        [retryButton sizeToFit];
        retryButton.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.timeLabel.topCenter = ccp(self.contentView.width/2, 6);
    if (self.isMyself) {
        self.avatarButton.rightTop = ccp(self.contentView.width-5, 6);
        self.contentBackground.size = ccs(self.contentLabel.width+7+18, self.contentLabel.height+14);
        self.contentBackground.rightTop = ccp(self.avatarButton.left-2, self.timeLabel.bottom+6);
        self.contentLabel.leftTop = ccp(self.contentBackground.left+7, self.contentBackground.top+7);
        self.retryButton.leftTop = ccp(5, self.contentBackground.top);
    } else {
        self.avatarButton.leftTop = ccp(5, 6);
        self.contentBackground.size = ccs(self.contentLabel.width+7+18, self.contentLabel.height+14);
        self.contentBackground.leftTop = ccp(self.avatarButton.right+2, self.timeLabel.bottom+6);
        self.contentLabel.leftTop = ccp(self.contentBackground.left+18, self.contentBackground.top+7);
    }
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    TTTAttributedLabel *testSizeLabel = [[TTTAttributedLabel alloc] init];
    testSizeLabel.textColor = rgb(38, 38, 38);
    testSizeLabel.font = [UIFont systemFontOfSize:14];
    testSizeLabel.backgroundColor = kClearColor;
    testSizeLabel.highlightedTextColor = kWhiteColor;
    testSizeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    testSizeLabel.numberOfLines = 0;
    testSizeLabel.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                                     (NSString *)kCTForegroundColorAttributeName: (id)cgrgb(30, 98, 164)};
    testSizeLabel.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgrgb(215, 230, 242),
                                           (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
    testSizeLabel.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    testSizeLabel.lineHeightMultiple = 1 + 4.0/14;
    
    testSizeLabel.text = data.rawData[@"text"];
    CGFloat textHeight = [testSizeLabel sizeThatFits:ccs(225, 0)].height;
    return MAX(6+10+5+7+textHeight+7+6, 6+50+6);
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    [self setupControl:self.retryButton forKey:@"retry"];
    
    self.retryButton.hidden = YES;
    if ([data.rawData[@"sending"] boolValue]) {
        if ([data.rawData[@"failed"] boolValue]) {
            self.timeLabel.text = @"Failed";
            self.retryButton.hidden = NO;
        } else {
            self.timeLabel.text = @"Sending...";
        }
    } else {
        NSDate *createdDate = [TWENGINE getDateFromTwitterCreatedAt:data.rawData[@"created_at"]];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"M/d/yyyy HH:mm:ss"];
        self.timeLabel.text = [df stringFromDate:createdDate];
    }
    [self.timeLabel sizeToFit];
    
    self.contentLabel.text = data.rawData[@"text"];
    self.myself = [MyScreenName isEqualToString:data.rawData[@"sender_screen_name"]];
    if (self.isMyself) {
        self.contentBackground.image = [[UIImage imageNamed:@"sms-right"] stretchableImageFromCenter];
    } else {
        self.contentBackground.image = [[UIImage imageNamed:@"sms-left"] stretchableImageFromCenter];
    }
    NSString *avatarUrl = data.rawData[@"sender"][@"profile_image_url_https"];
    avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
    [self.avatarButton setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal];
    self.contentLabel.size = [self.contentLabel sizeThatFits:ccs(225, 0)];
}

@end
