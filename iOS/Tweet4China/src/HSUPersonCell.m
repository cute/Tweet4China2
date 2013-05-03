//
//  HSUPersonCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUPersonCell.h"
#import "UIButton+WebCache.h"

@interface HSUPersonCell ()

@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *screenNameLabel;

@end

@implementation HSUPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *avatarButton = [[UIButton alloc] init];
        [self.contentView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        avatarButton.frame = ccr(14, 10, 32, 32);
        avatarButton.layer.cornerRadius = 4;
        avatarButton.layer.masksToBounds = YES;
        avatarButton.backgroundColor = bw(229);
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        nameLabel.textColor = kBlackColor;
        nameLabel.font = [UIFont boldSystemFontOfSize:14];
        nameLabel.highlightedTextColor = kWhiteColor;
        nameLabel.backgroundColor = kClearColor;
        nameLabel.frame = ccr(avatarButton.right+9, 10, 180, 18);
        
        UILabel *screenNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:screenNameLabel];
        self.screenNameLabel = screenNameLabel;
        screenNameLabel.textColor = kGrayColor;
        screenNameLabel.font = [UIFont systemFontOfSize:12];
        screenNameLabel.highlightedTextColor = kWhiteColor;
        screenNameLabel.backgroundColor = kClearColor;
        screenNameLabel.frame = ccr(avatarButton.right+9, 30, 180, 18);
        
        UIButton *followButton = [[UIButton alloc] init];
        [self.contentView addSubview:followButton];
        self.followButton = followButton;
        followButton.size = ccs(50, 29);
        followButton.top = 10;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.followButton.right = self.contentView.width - 10;
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    [self.avatarButton setImageWithURL:[NSURL URLWithString:data.rawData[@"profile_image_url_https"]]
                              forState:UIControlStateNormal];
    
    self.nameLabel.text = data.rawData[@"name"];
    
    self.screenNameLabel.text = data.rawData[@"screen_name"];
    
    if ([data.rawData[@"following"] boolValue]) {
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_following_default"] stretchableImageFromCenter]
                                     forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_following_pressed"] stretchableImageFromCenter]
                                     forState:UIControlStateHighlighted];
        [self.followButton setImage:[UIImage imageNamed:@"icn_follow_checked"] forState:UIControlStateNormal];
    } else {
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                     forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                     forState:UIControlStateHighlighted];
        [self.followButton setImage:[UIImage imageNamed:@"icn_follow_checked"] forState:UIControlStateNormal];
    }
    
    [self setupControl:self.followButton forKey:@"follow"];
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return 57;
}

@end
