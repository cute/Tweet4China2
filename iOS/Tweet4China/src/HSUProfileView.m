//
//  HSUProfileView.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUProfileView.h"
#import "UIButton+WebCache.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"

#define kLabelWidth 280
#define kNormalTextSize 13

@interface HSUProfileView ()

@property (nonatomic, strong) UIImageView *infoBGView;
@property (nonatomic, strong) UIScrollView *infoView;
@property (nonatomic, strong) UIPageControl *pager;
@property (nonatomic, strong) UIView *avatarBGView;
@property (nonatomic, strong) UIButton *avatarButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *screenNameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *siteLabel;

@property (nonatomic, strong) UIButton *tweetsButton;
@property (nonatomic, strong) UILabel *tweetsCountLabel;
@property (nonatomic, strong) UIButton *followingButton;
@property (nonatomic, strong) UILabel *followingCountLabel;
@property (nonatomic, strong) UIButton *followersButton;
@property (nonatomic, strong) UILabel *followersCountLabel;

@property (nonatomic, strong) UIButton *actionsButton;
@property (nonatomic, strong) UIButton *followButton;

@end

@implementation HSUProfileView

- (id)initWithScreenName:(NSString *)screenName delegate:(id<HSUProfileViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        UIImageView *infoBGView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_profile_empty"]];
        [self addSubview:infoBGView];
        self.infoBGView = infoBGView;
        
        UIPageControl *pager = [[UIPageControl alloc] init];
        [infoBGView addSubview:pager];
        self.pager = pager;
        pager.numberOfPages = 2;
        pager.size = ccs(30, 30);
        pager.bottomCenter = ccp(infoBGView.width/2, infoBGView.height);
        pager.backgroundColor = kClearColor;
        pager.hidden = YES;
        
        UIScrollView *infoView = [[UIScrollView alloc] init];
        [self addSubview:infoView];
        self.infoView = infoView;
        infoView.pagingEnabled = YES;
        infoView.frame = infoBGView.frame;
        infoView.contentSize = ccs(infoView.width*2, infoView.height);
        infoView.showsHorizontalScrollIndicator = NO;
        infoView.showsVerticalScrollIndicator = NO;
        infoView.delegate = self;
        
        UIView *avatarBGView = [[UIView alloc] init];
        [infoView addSubview:avatarBGView];
        self.avatarBGView = avatarBGView;
        avatarBGView.backgroundColor = kWhiteColor;
        avatarBGView.layer.cornerRadius = 4;
        avatarBGView.size = ccs(68, 68);
        avatarBGView.topCenter = ccp(infoView.width/2, 16);
        
        UIButton *avatarButton = [[UIButton alloc] init];
        [avatarBGView addSubview:avatarButton];
        self.avatarButton = avatarButton;
        avatarButton.backgroundColor = bw(229);
        avatarButton.layer.cornerRadius = 4;
        avatarButton.size = ccs(60, 60);
        avatarButton.center = avatarBGView.boundsCenter;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        [infoView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        nameLabel.font = [UIFont boldSystemFontOfSize:17];
        nameLabel.textColor = kWhiteColor;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.backgroundColor = kClearColor;
        nameLabel.size = ccs(kLabelWidth, 17*1.2);
        nameLabel.topCenter = ccp(infoView.width/2, avatarBGView.bottom+7);
        nameLabel.text = screenName.twitterScreenName;
        
        UILabel *screenNameLabel = [[UILabel alloc] init];
        [infoView addSubview:screenNameLabel];
        self.screenNameLabel = screenNameLabel;
        screenNameLabel.font = [UIFont systemFontOfSize:kNormalTextSize];
        screenNameLabel.textColor = kWhiteColor;
        screenNameLabel.textAlignment = NSTextAlignmentCenter;
        screenNameLabel.backgroundColor = kClearColor;
        screenNameLabel.size = ccs(kLabelWidth, kNormalTextSize*1.2);
        screenNameLabel.topCenter = ccp(infoView.width/2, nameLabel.bottom+5);
        screenNameLabel.text = screenName.twitterScreenName;
        
        UILabel *descLabel = [[UILabel alloc] init];
        [infoView addSubview:descLabel];
        self.descLabel = descLabel;
        descLabel.font = [UIFont systemFontOfSize:14];
        descLabel.textColor = kWhiteColor;
        descLabel.textAlignment = NSTextAlignmentCenter;
        descLabel.backgroundColor = kClearColor;
        descLabel.lineBreakMode = NSLineBreakByWordWrapping;
        descLabel.numberOfLines = 2;
        descLabel.size = ccs(kLabelWidth, 32);
        descLabel.topCenter = ccp(infoView.width/2*3, 40);
        
        UILabel *locationLabel = [[UILabel alloc] init];
        [infoView addSubview:locationLabel];
        self.locationLabel = locationLabel;
        locationLabel.font = [UIFont systemFontOfSize:kNormalTextSize];
        locationLabel.textColor = kWhiteColor;
        locationLabel.textAlignment = NSTextAlignmentCenter;
        locationLabel.backgroundColor = kClearColor;
        locationLabel.size = ccs(kLabelWidth, kNormalTextSize*1.2);
        locationLabel.topCenter = ccp(infoView.width/2*3, descLabel.bottom+5);
        
        UILabel *siteLabel = [[UILabel alloc] init];
        [infoView addSubview:siteLabel];
        self.siteLabel = siteLabel;
        siteLabel.font = [UIFont boldSystemFontOfSize:kNormalTextSize];
        siteLabel.textColor = kWhiteColor;
        siteLabel.textAlignment = NSTextAlignmentCenter;
        siteLabel.backgroundColor = kClearColor;
        siteLabel.size = ccs(kLabelWidth, kNormalTextSize*1.2);
        siteLabel.topCenter = ccp(infoView.width/2*3, locationLabel.bottom+5);
        
        self.frame = infoView.bounds;
        
        UIView *referenceButtonBGView = [[UIView alloc] init];
        [self addSubview:referenceButtonBGView];
        referenceButtonBGView.backgroundColor = bw(232);
        referenceButtonBGView.frame = ccr(0, infoView.bottom, self.width, 48);
        
        UIButton *tweetsButton = [[UIButton alloc] init];
        [referenceButtonBGView addSubview:tweetsButton];
        self.tweetsButton = tweetsButton;
        tweetsButton.backgroundColor = kWhiteColor;
        tweetsButton.frame = ccr(0, 1, 107, referenceButtonBGView.height-2);
        [tweetsButton setTitleColor:bw(153) forState:UIControlStateNormal];
        tweetsButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [tweetsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -55, 0, 0)];
        [tweetsButton setTitle:@"TWEETS" forState:UIControlStateNormal];
        [tweetsButton setTapTarget:delegate action:@selector(tweetsButtonTouched)];
        
        UILabel *tweetsCountLabel = [[UILabel alloc] init];
        [tweetsButton addSubview:tweetsCountLabel];
        self.tweetsCountLabel = tweetsCountLabel;
        tweetsCountLabel.backgroundColor = kClearColor;
        tweetsCountLabel.font = [UIFont boldSystemFontOfSize:13];
        tweetsCountLabel.textColor = kBlackColor;
        tweetsCountLabel.leftTop = ccp(10, 9);
        
        UIButton *followingButton = [[UIButton alloc] init];
        [referenceButtonBGView addSubview:followingButton];
        self.followingButton = followingButton;
        followingButton.backgroundColor = kWhiteColor;
        followingButton.frame = ccr(tweetsButton.right+1, 1, 105, tweetsButton.height);
        [followingButton setTitleColor:bw(153) forState:UIControlStateNormal];
        followingButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [followingButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -38.5, 0, 0)];
        [followingButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
        [followingButton setTapTarget:delegate action:@selector(followingButtonTouched)];
        
        UILabel *followingCountLabel = [[UILabel alloc] init];
        [followingButton addSubview:followingCountLabel];
        self.followingCountLabel = followingCountLabel;
        followingCountLabel.backgroundColor = kClearColor;
        followingCountLabel.font = [UIFont boldSystemFontOfSize:13];
        followingCountLabel.textColor = kBlackColor;
        followingCountLabel.leftTop = ccp(10, 9);
        
        UIButton *followersButton = [[UIButton alloc] init];
        [referenceButtonBGView addSubview:followersButton];
        self.followersButton = followersButton;
        followersButton.backgroundColor = kWhiteColor;
        followersButton.frame = ccr(followingButton.right+1, 1, 106, followingButton.height);
        [followersButton setTitleColor:bw(153) forState:UIControlStateNormal];
        followersButton.titleLabel.font = [UIFont systemFontOfSize:8];
        [followersButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -37.5, 0, 0)];
        [followersButton setTitle:@"FOLLOWERS" forState:UIControlStateNormal];
        [followersButton setTapTarget:delegate action:@selector(followersButtonTouched)];
        
        UILabel *followersCountLabel = [[UILabel alloc] init];
        [followersButton addSubview:followersCountLabel];
        self.followersCountLabel = followersCountLabel;
        followersCountLabel.backgroundColor = kClearColor;
        followersCountLabel.font = [UIFont boldSystemFontOfSize:13];
        followersCountLabel.textColor = kBlackColor;
        followersCountLabel.leftTop = ccp(10, 9);
        
        
        UIView *buttonsPanel = [[UIView alloc] init];
        [self addSubview:buttonsPanel];
        buttonsPanel.frame = ccr(0, referenceButtonBGView.bottom, self.width, 48);
        buttonsPanel.backgroundColor = kWhiteColor;
        
        if ([screenName isEqualToString:MyScreenName]) {
            UIButton *settingsButton = [[UIButton alloc] init];
            [buttonsPanel addSubview:settingsButton];
            [settingsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                      forState:UIControlStateNormal];
            [settingsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                      forState:UIControlStateHighlighted];
            [settingsButton setImage:[UIImage imageNamed:@"icn_profile_settings"] forState:UIControlStateNormal];
            settingsButton.size = ccs(42, 30);
            settingsButton.leftCenter = ccp(10, buttonsPanel.height/2);
            
            UIButton *accountsButton = [[UIButton alloc] init];
            [buttonsPanel addSubview:accountsButton];
            [accountsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                      forState:UIControlStateNormal];
            [accountsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                      forState:UIControlStateHighlighted];
            [accountsButton setImage:[UIImage imageNamed:@"icn_profile_switch_accounts"] forState:UIControlStateNormal];
            accountsButton.size = ccs(42, 30);
            accountsButton.leftCenter = ccp(settingsButton.right + 10, buttonsPanel.height/2);
            
            UIButton *messagesButton = [[UIButton alloc] init];
            [buttonsPanel addSubview:messagesButton];
            [messagesButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                      forState:UIControlStateNormal];
            [messagesButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                      forState:UIControlStateHighlighted];
            [messagesButton setImage:[UIImage imageNamed:@"icn_profile_messages"] forState:UIControlStateNormal];
            messagesButton.size = ccs(42, 30);
            messagesButton.rightCenter = ccp(buttonsPanel.width - 10, buttonsPanel.height/2);
        } else {
            UIButton *actionsButton = [[UIButton alloc] init];
            [buttonsPanel addSubview:actionsButton];
            self.actionsButton = actionsButton;
            [actionsButton setTapTarget:delegate action:@selector(actionsButtonTouched)];
            [actionsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                     forState:UIControlStateNormal];
            [actionsButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                     forState:UIControlStateHighlighted];
            [actionsButton setImage:[UIImage imageNamed:@"icn_profile_action"] forState:UIControlStateNormal];
            actionsButton.size = ccs(42, 30);
            actionsButton.leftCenter = ccp(10, buttonsPanel.height/2);
            
            UIButton *followButton = [[UIButton alloc] init];
            [buttonsPanel addSubview:followButton];
            self.followButton = followButton;
            [followButton setTapTarget:delegate action:@selector(followButtonTouched:)];
            followButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
            followButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
            followButton.size = ccs(90, 30);
            followButton.rightCenter = ccp(buttonsPanel.width - 10, buttonsPanel.height/2);
        }
        
        self.height = buttonsPanel.bottom;
    }
    return self;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pager.currentPage = scrollView.contentOffset.x / self.infoView.width;
}

- (void)setupWithProfile:(NSDictionary *)profile
{
    [self.infoBGView sizeToFit];
    NSString *avatarUrl = profile[@"profile_image_url_https"];
    avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
    [self.avatarButton setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal];
    self.screenNameLabel.text = [profile[@"screen_name"] twitterScreenName];
    self.nameLabel.text = profile[@"name"];
    self.descLabel.text = profile[@"description"];
    [self.descLabel sizeToFit];
    self.locationLabel.text = profile[@"location"];
    self.siteLabel.text = [self _websiteForProfile:profile];
    self.pager.hidden = NO;
    NSString *bannerUrl = [profile[@"profile_banner_url"] stringByAppendingString:@"/mobile_retina"];
    [self.infoBGView setImageWithURL:[NSURL URLWithString:bannerUrl] placeholderImage:[UIImage imageNamed:@"bg_profile_empty"]];
    
    self.tweetsCountLabel.text = [NSString stringSplitWithCommaFromInteger:[profile[@"statuses_count"] integerValue]];
    [self.tweetsCountLabel sizeToFit];
    self.tweetsButton.titleEdgeInsets = UIEdgeInsetsMake(16, self.tweetsButton.titleEdgeInsets.left, self.tweetsButton.titleEdgeInsets.bottom, self.tweetsButton.titleEdgeInsets.right);
    self.followingCountLabel.text = [NSString stringSplitWithCommaFromInteger:[profile[@"statuses_count"] integerValue]];
    [self.followingCountLabel sizeToFit];
    self.followingButton.titleEdgeInsets = UIEdgeInsetsMake(16, self.followingButton.titleEdgeInsets.left, self.followingButton.titleEdgeInsets.bottom, self.followingButton.titleEdgeInsets.right);
    self.followersCountLabel.text = [NSString stringSplitWithCommaFromInteger:[profile[@"statuses_count"] integerValue]];
    [self.followersCountLabel sizeToFit];
    self.followersButton.titleEdgeInsets = UIEdgeInsetsMake(16, self.followersButton.titleEdgeInsets.left, self.followersButton.titleEdgeInsets.bottom, self.followersButton.titleEdgeInsets.right);
    
    if ([profile[@"following"] boolValue]) {
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_following_default"] stretchableImageFromCenter]
                                     forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_following_pressed"] stretchableImageFromCenter]
                                     forState:UIControlStateNormal];
        [self.followButton setImage:nil forState:UIControlStateNormal];
        [self.followButton setTitleShadowColor:kBlackColor forState:UIControlStateNormal];
        self.followButton.titleLabel.shadowOffset = ccs(0, -1);
        [self.followButton setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
    } else {
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_default"] stretchableImageFromCenter]
                                forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[[UIImage imageNamed:@"btn_floating_segment_selected"] stretchableImageFromCenter]
                                forState:UIControlStateHighlighted];
        [self.followButton setImage:[UIImage imageNamed:@"ic_follow_text"] forState:UIControlStateNormal];
        self.followButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.followButton setTitleShadowColor:kWhiteColor forState:UIControlStateNormal];
        self.followButton.titleLabel.shadowOffset = ccs(0, 1);
        [self.followButton setTitleColor:bw(51) forState:UIControlStateNormal];
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    }
}

- (NSString *)_websiteForProfile:(NSDictionary *)profile
{
    NSArray *urls = profile[@"entities"][@"url"][@"urls"];
    if (urls.count) {
        NSString *displayUrl = urls[0][@"display_url"];
        if (displayUrl.length) {
            return displayUrl;
        }
        return [[urls[0][@"url"]
                 stringByReplacingOccurrencesOfString:@"http://" withString:@""]
                stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    }
    return nil;
}

@end
