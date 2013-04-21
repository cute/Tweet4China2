//
//  HSUStatusDetailCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/18/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUMainStatusCell.h"

#import "HSUStatusCell.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Additions.h"
#import "FHSTwitterEngine.h"
#import "GTMNSString+HTML.h"
#import "UIButton+WebCache.h"

#define ambient_H 14
#define info_H 16
#define textAL_font_S 16
#define margin_W 10
#define padding_S 10
#define avatar_S 48
#define ambient_S 20
#define textAL_LHM 1.2
#define actionV_H 44
#define avatar_text_Distance 15

#define retweeted_R @"ic_ambient_retweet"
#define attr_photo_R @"ic_tweet_attr_photo_default"
#define attr_convo_R @"ic_tweet_attr_convo_default"
#define attr_summary_R @"ic_tweet_attr_summary_default"

@implementation HSUMainStatusCell
{
    UIView *contentArea;
    UIView *ambientArea;
    UIImageView *ambientI;
    UILabel *ambientL;
    UIImageView *avatarI;
    UILabel *nameL;
    UILabel *screenNameL;
    UILabel *timeL;
    TTTAttributedLabel *textAL;
    UIImageView *flagIV;
    
    UIView *actionSeperatorV;
    UIView *actionV;
    UIButton *replayB, *retweetB, *favoriteB, *moreB;
    BOOL retweeted, favorited;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        contentArea = [[UIView alloc] init];
        [self.contentView addSubview:contentArea];
        
        ambientArea = [[UIView alloc] init];
        [contentArea addSubview:ambientArea];
        
        ambientI = [[UIImageView alloc] init];
        [ambientArea addSubview:ambientI];
        
        ambientL = [[UILabel alloc] init];
        [ambientArea addSubview:ambientL];
        ambientL.font = [UIFont systemFontOfSize:13];
        ambientL.textColor = [UIColor grayColor];
        ambientL.highlightedTextColor = kWhiteColor;
        ambientL.backgroundColor = kClearColor;
        
        avatarI = [[UIImageView alloc] init];
        [contentArea addSubview:avatarI];
        avatarI.layer.cornerRadius = 5;
        avatarI.layer.masksToBounds = YES;
        
        nameL = [[UILabel alloc] init];
        [contentArea addSubview:nameL];
        nameL.font = [UIFont boldSystemFontOfSize:14];
        nameL.textColor = [UIColor blackColor];
        nameL.highlightedTextColor = kWhiteColor;
        nameL.backgroundColor = kClearColor;
        
        screenNameL = [[UILabel alloc] init];
        [contentArea addSubview:screenNameL];
        screenNameL.font = [UIFont systemFontOfSize:12];
        screenNameL.textColor = [UIColor grayColor];
        screenNameL.highlightedTextColor = kWhiteColor;
        screenNameL.backgroundColor = kClearColor;
        
        timeL = [[UILabel alloc] init];
        [contentArea addSubview:timeL];
        timeL.font = [UIFont systemFontOfSize:12];
        timeL.textColor = [UIColor grayColor];
        timeL.highlightedTextColor = kWhiteColor;
        timeL.backgroundColor = kClearColor;
        
        textAL = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [contentArea addSubview:textAL];
        textAL.font = [UIFont systemFontOfSize:textAL_font_S];
        textAL.backgroundColor = kClearColor;
        textAL.textColor = rgb(38, 38, 38);
        textAL.highlightedTextColor = kWhiteColor;
        textAL.lineBreakMode = NSLineBreakByWordWrapping;
        textAL.numberOfLines = 0;
        textAL.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                                  (NSString *)kCTForegroundColorAttributeName: (id)cgrgb(30, 98, 164)};
        textAL.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgrgb(215, 230, 242),
                                        (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
        textAL.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        textAL.lineHeightMultiple = textAL_LHM;
        
        flagIV = [[UIImageView alloc] init];
        [self.contentView addSubview:flagIV];
        
        // action buttons
        actionSeperatorV = [[UIView alloc] init];
        actionSeperatorV.backgroundColor = bw(226);
        [self.contentView addSubview:actionSeperatorV];
        
        actionV = [[UIView alloc] init];
        [self.contentView addSubview:actionV];
        
        replayB = [[UIButton alloc] init];
        replayB.showsTouchWhenHighlighted = YES;
        [replayB setImage:[UIImage imageNamed:@"icn_tweet_action_reply"] forState:UIControlStateNormal];
        [replayB sizeToFit];
        [actionV addSubview:replayB];
        
        retweetB = [[UIButton alloc] init];
        retweetB.showsTouchWhenHighlighted = YES;
        if (retweeted)
            [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_on"] forState:UIControlStateNormal];
        else
            [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_off"] forState:UIControlStateNormal];
        [retweetB sizeToFit];
        [actionV addSubview:retweetB];
        
        favoriteB = [[UIButton alloc] init];
        favoriteB.showsTouchWhenHighlighted = YES;
        if (favorited)
            [favoriteB setImage:[UIImage imageNamed:@"icn_tweet_action_favorite_on"] forState:UIControlStateNormal];
        else
            [favoriteB setImage:[UIImage imageNamed:@"icn_tweet_action_favorite_off"] forState:UIControlStateNormal];
        [favoriteB sizeToFit];
        [actionV addSubview:favoriteB];
        
        moreB = [[UIButton alloc] init];
        moreB.showsTouchWhenHighlighted = YES;
        [moreB setImage:[UIImage imageNamed:@"icn_tweet_action_more"] forState:UIControlStateNormal];
        [moreB sizeToFit];
        [actionV addSubview:moreB];
        
        // set frames
        contentArea.frame = ccr(padding_S, padding_S, self.contentView.width-padding_S*4, 0);
        CGFloat cw = contentArea.width;
        ambientArea.frame = ccr(0, 0, cw, ambient_H);
        ambientI.frame = ccr(avatar_S-ambient_S, (ambient_H-ambient_S)/2, ambient_S, ambient_S);
        ambientL.frame = ccr(avatar_S+padding_S, 0, cw-ambientI.right-padding_S, ambient_H);
        avatarI.frame = ccr(0, 0, avatar_S, avatar_S);
        textAL.frame = ccr(avatarI.left, 0, cw, 0);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    contentArea.frame = ccr(contentArea.left, contentArea.top, contentArea.width, self.contentView.height-padding_S*2);
    ambientArea.frame = ccr(0, 0, contentArea.width, ambient_S);
    
    if (ambientArea.hidden) {
        avatarI.leftTop = ccp(avatarI.left, 0);
    } else {
        avatarI.leftTop = ccp(avatarI.left, ambientArea.bottom);
    }
    
    textAL.frame = ccr(textAL.left, avatarI.bottom+avatar_text_Distance, textAL.width, [self.data.renderData[@"text_height"] floatValue]+3);
    
    [timeL sizeToFit];
    timeL.leftTop = ccp(textAL.left, textAL.bottom+avatar_text_Distance);
    
    [nameL sizeToFit];
    nameL.leftTop = ccp(avatarI.right+padding_S, avatarI.top+7);
    
    [screenNameL sizeToFit];
    screenNameL.leftTop = ccp(nameL.left, nameL.bottom+3);
    
    [flagIV sizeToFit];
    flagIV.rightTop = ccp(self.contentView.width, 0);
    
    actionV.frame = ccr(0, 0, self.contentView.width, actionV_H);
    actionV.bottom = self.contentView.height;
    
    actionSeperatorV.frame = ccr(9, actionV.top-1, actionV.width-9*2, 1);
    
    replayB.center = ccp(actionV.width/8, actionV.height/2);
    retweetB.center = ccp(actionV.width*3/8, actionV.height/2);
    favoriteB.center = ccp(actionV.width*5/8, actionV.height/2);
    moreB.center = ccp(actionV.width*7/8, actionV.height/2);
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
    }
    
    // ambient
    ambientI.hidden = NO;
    NSDictionary *retweetedStatus = rawData[@"retweeted_status"];
    if (retweetedStatus) {
        ambientI.imageName = retweeted_R;
        NSString *ambientText = [NSString stringWithFormat:@"%@ retweeted", rawData[@"user"][@"name"]];
        ambientL.text = ambientText;
        ambientArea.hidden = NO;
    } else {
        ambientI.imageName = nil;
        ambientL.text = nil;
        ambientArea.hidden = YES;
        ambientArea.bounds = CGRectZero;
    }
    
    NSDictionary *entities = rawData[@"entities"];
    
    // info
    NSString *avatarUrl = nil;
    if (retweetedStatus) {
        avatarUrl = rawData[@"retweeted_status"][@"user"][@"profile_image_url_https"];
        nameL.text = rawData[@"retweeted_status"][@"user"][@"name"];
        screenNameL.text = [NSString stringWithFormat:@"@%@", rawData[@"retweeted_status"][@"user"][@"screen_name"]];
    } else {
        avatarUrl = rawData[@"user"][@"profile_image_url_https"];
        nameL.text = rawData[@"user"][@"name"];
        screenNameL.text = [NSString stringWithFormat:@"@%@", rawData[@"user"][@"screen_name"]];
    }
    avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
    [avatarI setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"ProfilePlaceholderOverBlue"]];
    UIButton *b;
    [b setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ProfilePlaceholderOverBlue"]];
    [b setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage:[UIImage imageNamed:@"avatar_pressed"]];
    
    // time
    NSDate *createdDate = [[FHSTwitterEngine engine] getDateFromTwitterCreatedAt:rawData[@"created_at"]];
    timeL.text = createdDate.standardTwitterDisplay;
    
    // text
    NSString *text = [rawData[@"text"] gtm_stringByUnescapingFromHTML];
    textAL.text = text;
    if (entities) {
        NSMutableArray *urlDicts = [NSMutableArray array];
        NSArray *urls = entities[@"urls"];
        NSArray *medias = entities[@"media"];
        if (urls && urls.count) {
            [urlDicts addObjectsFromArray:urls];
        }
        if (medias && medias.count) {
            [urlDicts addObjectsFromArray:medias];
        }
        if (urlDicts && urlDicts.count) {
            for (NSDictionary *urlDict in urlDicts) {
                NSString *url = urlDict[@"url"];
                NSString *displayUrl = urlDict[@"display_url"];
                if (url && url.length && displayUrl && displayUrl.length) {
                    text = [text stringByReplacingOccurrencesOfString:url withString:displayUrl];
                }
            }
            textAL.text = text;
            for (NSDictionary *urlDict in urlDicts) {
                NSString *url = urlDict[@"url"];
                NSString *displayUrl = urlDict[@"display_url"];
                NSString *expanedUrl = urlDict[@"expanded_url"];
                if (url && url.length && displayUrl && displayUrl.length && expanedUrl && expanedUrl.length) {
                    NSRange range = [text rangeOfString:displayUrl];
                    [textAL addLinkToURL:[NSURL URLWithString:expanedUrl] withRange:range];
                }
            }
        }
    }
    textAL.delegate = data.renderData[@"attributed_label_delegate"];
    
    // set action events
    [self setupControl:replayB forKey:@"reply" withData:self.data cleanOldEvents:YES];
    [self setupControl:retweetB forKey:@"retweet" withData:self.data cleanOldEvents:YES];
    [self setupControl:favoriteB forKey:@"favorite" withData:self.data cleanOldEvents:YES];
    [self setupControl:moreB forKey:@"more" withData:self.data cleanOldEvents:YES];
}

+ (CGFloat)_textHeightWithCellData:(HSUTableCellData *)data
{
    NSDictionary *status = data.rawData;
    NSString *text = [status[@"text"] gtm_stringByUnescapingFromHTML];
    NSDictionary *entities = status[@"entities"];
    if (entities) {
        NSArray *urls = entities[@"urls"];
        NSArray *medias = entities[@"media"];
        if (medias && medias.count) {
            urls = [urls arrayByAddingObjectsFromArray:medias];
        }
        if (urls && urls.count) {
            for (NSDictionary *urlDict in urls) {
                NSString *url = urlDict[@"url"];
                NSString *displayUrl = urlDict[@"display_url"];
                if (url && url.length && displayUrl && displayUrl.length) {
                    text = [text stringByReplacingOccurrencesOfString:url withString:displayUrl];
                }
            }
        }
    }
    
    static TTTAttributedLabel *testSizeLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TTTAttributedLabel *textAL = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        textAL.font = [UIFont systemFontOfSize:textAL_font_S];
        textAL.backgroundColor = kClearColor;
        textAL.textColor = rgb(38, 38, 38);
        textAL.highlightedTextColor = kWhiteColor;
        textAL.lineBreakMode = NSLineBreakByWordWrapping;
        textAL.numberOfLines = 0;
        textAL.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                                  (NSString *)kCTForegroundColorAttributeName: (id)cgrgb(30, 98, 164)};
        textAL.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgrgb(215, 230, 242),
                                        (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
        textAL.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        textAL.lineHeightMultiple = textAL_LHM;
        
        testSizeLabel = textAL;
    });
    testSizeLabel.text = text;
    
    CGFloat cellWidth = [HSUCommonTools winWidth] - padding_S * 4;
    CGFloat textHeight = [testSizeLabel sizeThatFits:ccs(cellWidth, 0)].height;
    data.renderData[@"text_height"] = @(textHeight);
    return [testSizeLabel sizeThatFits:ccs(cellWidth, 0)].height;
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    NSDictionary *rawData = data.rawData;
    NSMutableDictionary *renderData = data.renderData;
    if (renderData) {
        if (renderData[@"height"]) {
            return [renderData[@"height"] floatValue];
        }
    }
    
    CGFloat height = 0;
    
    height += padding_S; // add padding top
    
    if (rawData[@"retweeted_status"]) {
        height += ambient_H; // add ambient
    }
    
    // avatar
    height += avatar_S;
    height += avatar_text_Distance;
    
    // text height
    height += [self _textHeightWithCellData:data];;
    height += avatar_text_Distance;
    
    // timeL height
    height += 15;
    height += avatar_text_Distance;
    
    // actionV height
    height += actionV_H + 1;
    
    // as integer
    height = floorf(height);
    
    renderData[@"height"] = @(height);
    
    return height;
}

- (TTTAttributedLabel *)contentLabel
{
    return textAL;
}

+ (NSString *)attrForUrl:(NSString *)url
{
    if ([url hasPrefix:@"http://4sq.com"] ||
        [url hasPrefix:@"http://youtube.com"]) {
        return @"summary";
    } else if ([url hasPrefix:@"http://youtube.com"] ||
               [url hasPrefix:@"http://snpy.tv"]) {
        return @"video";
    } else if ([url hasPrefix:@"http://instagram.com"] || [url hasPrefix:@"http://instagr.am"]) {
        return @"photo";
    }
    return nil;
}

@end
