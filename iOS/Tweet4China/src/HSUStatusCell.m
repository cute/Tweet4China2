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
#import "NSDate+Additions.h"
#import "UIView+Additions.h"
#import "FHSTwitterEngine.h"
#import "FHSTwitterEngine+Additions.h"

#define ambient_H 14
#define info_H 16
#define textAL_font_S 14
#define margin_W 10
#define padding_S 10
#define avatar_S 48
#define ambient_S 20
#define textAL_LHM 1.3

#define retweeted_R @"ic_ambient_retweet"
#define avatarPlaceholder_R @"avatar_pressed"
#define attr_photo_R @"ic_tweet_attr_photo_default"
#define attr_convo_R @"ic_tweet_attr_convo_default"
#define attr_summary_R @"ic_tweet_attr_summary_default"

@implementation HSUStatusCell
{
    UIView *contentArea;
    UIView *ambientArea;
    UIImageView *ambientI;
    UILabel *ambientL;
    UIImageView *avatarI;
    UIView *infoArea;
    UILabel *nameL;
    UILabel *screenNameL;
    UIImageView *attrI; // photo/video/geo/summary/audio/convo
    UILabel *timeL;
    TTTAttributedLabel *textAL;
    
    NSArray *ambientAreaConstraints;
    NSArray *infoAreaConstraints;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        
        contentArea = [[UIView alloc] init];
        [self.contentView addSubview:contentArea];
        
        ambientArea = [[UIView alloc] init];
        [contentArea addSubview:ambientArea];
        
        infoArea = [[UIView alloc] init];
        [contentArea addSubview:infoArea];
        
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
        [infoArea addSubview:nameL];
        nameL.font = [UIFont boldSystemFontOfSize:14];
        nameL.textColor = [UIColor blackColor];
        nameL.highlightedTextColor = kWhiteColor;
        nameL.backgroundColor = kClearColor;
        
        screenNameL = [[UILabel alloc] init];
        [infoArea addSubview:screenNameL];
        screenNameL.font = [UIFont systemFontOfSize:12];
        screenNameL.textColor = [UIColor grayColor];
        screenNameL.highlightedTextColor = kWhiteColor;
        screenNameL.backgroundColor = kClearColor;
        
        attrI = [[UIImageView alloc] init];
        [infoArea addSubview:attrI];
        
        timeL = [[UILabel alloc] init];
        [infoArea addSubview:timeL];
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
        
        
        contentArea.frame = ccr(padding_S, padding_S, self.contentView.width-padding_S*4, 0);
        CGFloat cw = contentArea.width;
        ambientArea.frame = ccr(0, 0, cw, ambient_H);
        ambientI.frame = ccr(avatar_S-ambient_S, (ambient_H-ambient_S)/2, ambient_S, ambient_S);
        ambientL.frame = ccr(avatar_S+padding_S, 0, cw-ambientI.right-padding_S, ambient_H);
        avatarI.frame = ccr(0, 0, avatar_S, avatar_S);
        infoArea.frame = ccr(ambientL.left, 0, cw-ambientL.left, info_H);
        attrI.frame = ccr(0, 0, 0, 16);
        textAL.frame = ccr(ambientL.left, 0, infoArea.width, 0);
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    contentArea.frame = ccr(contentArea.left, contentArea.top, contentArea.width, self.contentView.height-padding_S*2);
    ambientArea.frame = ccr(0, 0, contentArea.width, ambient_S);
    
    if (ambientArea.hidden) {
        avatarI.frame = ccr(avatarI.left, 0, avatarI.width, avatarI.height);
    } else {
        avatarI.frame = ccr(avatarI.left, ambientArea.bottom, avatarI.width, avatarI.height);
    }
    
    infoArea.frame = ccr(infoArea.left, avatarI.top, infoArea.width, infoArea.height);
    textAL.frame = ccr(textAL.left, infoArea.bottom, textAL.width, contentArea.height-infoArea.bottom);
    
    [timeL sizeToFit];
    timeL.frame = ccr(infoArea.width-timeL.width, -1, timeL.width, timeL.height);
    
    [attrI sizeToFit];
    attrI.frame = ccr(timeL.left-attrI.width-3, -1, attrI.width, attrI.height);
    
    [nameL sizeToFit];
    nameL.frame = ccr(0, -3, MIN(attrI.left-3, nameL.width), nameL.height);
    
    [screenNameL sizeToFit];
    screenNameL.frame = ccr(nameL.right+3, -1, attrI.left-nameL.right, screenNameL.height);
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    NSDictionary *rawData = data.rawData;
    
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
    if (retweetedStatus) {
        NSString *avatarUrl = rawData[@"retweeted_status"][@"user"][@"profile_image_url_https"];
        avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
        [avatarI setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:avatarPlaceholder_R]];
        
        nameL.text = rawData[@"retweeted_status"][@"user"][@"name"];
        screenNameL.text = [NSString stringWithFormat:@"@%@", rawData[@"retweeted_status"][@"user"][@"screen_name"]];
    } else {
        NSString *avatarUrl = rawData[@"user"][@"profile_image_url_https"];
        avatarUrl = [avatarUrl stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"];
        [avatarI setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:avatarPlaceholder_R]];
        
        nameL.text = rawData[@"user"][@"name"];
        screenNameL.text = [NSString stringWithFormat:@"@%@", rawData[@"user"][@"screen_name"]];
    }
    
    // attr
    attrI.imageName = nil;
    while (YES) {
        if ([rawData[@"in_reply_to_status_id_str"] length]) {
            attrI.imageName = attr_convo_R;
            break;
        }
        NSArray *medias = rawData[@"entities"][@"media"];
        if (medias && medias.count) {
            NSDictionary *media = medias[0];
            NSString *type = media[@"type"];
            if ([type isEqualToString:@"photo"]) {
                attrI.imageName = attr_photo_R;
                break;
            }
        }
        if (entities) {
            NSArray *urls = entities[@"urls"];
            if (urls && urls.count) {
                for (NSDictionary *urlDict in urls) {
                    NSString *expandedUrl = urlDict[@"expanded_url"];
                    attrI.imageName = S(@"ic_tweet_attr_%@_default", [HSUStatusCell attrForUrl:expandedUrl]);
                }
            }
        }
        break;
    }
    
    // time
    NSDate *createdDate = [[FHSTwitterEngine engine] getDateFromTwitterCreatedAt:rawData[@"created_at"]];
    timeL.text = createdDate.twitterDisplay;
    
    // text
    NSString *text = rawData[@"text"];
    textAL.text = text;
    if (entities) {
        NSArray *urls = entities[@"urls"];
        if (urls && urls.count) {
            for (NSDictionary *urlDict in urls) {
                NSString *url = urlDict[@"url"];
                NSString *displayUrl = urlDict[@"display_url"];
                if (url && url.length && displayUrl && displayUrl.length) {
                    text = [text stringByReplacingOccurrencesOfString:url withString:displayUrl];
                }
            }
            textAL.text = text;
            for (NSDictionary *urlDict in urls) {
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
    CGFloat leftHeight = 0;
    
    height += padding_S; // add padding top
    leftHeight += padding_S;
    
    if (rawData[@"retweeted_status"]) {
        height += ambient_H; // add ambient
        leftHeight += ambient_H;
    }
    height += info_H; // add info
    
    NSString *text = rawData[@"text"];
    NSDictionary *entities = rawData[@"entities"];
    if (entities) {
        NSArray *urls = entities[@"urls"];
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
    CGFloat cellWidth = [HSUCommonTools winWidth] - margin_W * 2 - padding_S * 3 - avatar_S;
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:textAL_font_S] constrainedToSize:CGSizeMake(cellWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height); // add text
    
    leftHeight += avatar_S; // add avatar
    
    height += padding_S; // add padding-bottom
    leftHeight += padding_S;
    
    height *= textAL_LHM;
    height -= (textAL_LHM - 1) * textAL_font_S;
    
    CGFloat cellHeight = MAX(height, leftHeight);
    renderData[@"height"] = @(cellHeight);
    
    return cellHeight;
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
