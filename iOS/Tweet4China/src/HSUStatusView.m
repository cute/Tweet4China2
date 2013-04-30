//
//  HSUStatusView.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/27/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUStatusView.h"
#import "UIImageView+AFNetworking.h"
#import "GTMNSString+HTML.h"
#import "AFNetworking.h"

#define ambient_H 14
#define info_H 16
#define textAL_font_S 14
#define margin_W 10
#define avatar_S 48
#define ambient_S 20
#define textAL_LHM 1.3
#define padding_S 10

#define retweeted_R @"ic_ambient_retweet"
#define attr_photo_R @"ic_tweet_attr_photo_default"
#define attr_convo_R @"ic_tweet_attr_convo_default"
#define attr_summary_R @"ic_tweet_attr_summary_default"

@implementation HSUStatusView
{
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
}

- (id)initWithFrame:(CGRect)frame style:(HSUStatusViewStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style;
        
        ambientArea = [[UIView alloc] init];
        [self addSubview:ambientArea];
        
        infoArea = [[UIView alloc] init];
        [self addSubview:infoArea];
        
        ambientI = [[UIImageView alloc] init];
        [ambientArea addSubview:ambientI];
        
        ambientL = [[UILabel alloc] init];
        [ambientArea addSubview:ambientL];
        
        avatarI = [[UIImageView alloc] init];
        [self addSubview:avatarI];
        
        nameL = [[UILabel alloc] init];
        [infoArea addSubview:nameL];
        
        screenNameL = [[UILabel alloc] init];
        [infoArea addSubview:screenNameL];
        
        attrI = [[UIImageView alloc] init];
        [infoArea addSubview:attrI];
        
        timeL = [[UILabel alloc] init];
        [infoArea addSubview:timeL];
        
        textAL = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        [self addSubview:textAL];
        
        [self _setupStyle];
    }
    return self;
}

- (void)_setupStyle
{
    ambientL.textColor = kGrayColor;
    ambientL.font = [UIFont systemFontOfSize:13];
    ambientL.highlightedTextColor = kWhiteColor;
    ambientL.backgroundColor = kClearColor;
    
    nameL.textColor = kBlackColor;
    nameL.font = [UIFont boldSystemFontOfSize:14];
    nameL.highlightedTextColor = kWhiteColor;
    nameL.backgroundColor = kClearColor;
    
    avatarI.layer.cornerRadius = 5;
    avatarI.layer.masksToBounds = YES;
    
    screenNameL.textColor = kGrayColor;
    screenNameL.font = [UIFont systemFontOfSize:12];
    screenNameL.highlightedTextColor = kWhiteColor;
    screenNameL.backgroundColor = kClearColor;
    
    timeL.textColor = kGrayColor;
    timeL.font = [UIFont systemFontOfSize:12];
    timeL.highlightedTextColor = kWhiteColor;
    timeL.backgroundColor = kClearColor;
    
    textAL.textColor = rgb(38, 38, 38);
    textAL.font = [UIFont systemFontOfSize:textAL_font_S];
    textAL.backgroundColor = kClearColor;
    textAL.highlightedTextColor = kWhiteColor;
    textAL.lineBreakMode = NSLineBreakByWordWrapping;
    textAL.numberOfLines = 0;
    textAL.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                              (NSString *)kCTForegroundColorAttributeName: (id)cgrgb(30, 98, 164)};
    textAL.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgrgb(215, 230, 242),
                                    (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
    textAL.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
    textAL.lineHeightMultiple = textAL_LHM;
    
    if (self.style == HSUStatusViewStyle_Gallery) {
        attrI.hidden = YES;
        ambientL.textColor = kWhiteColor;
        nameL.textColor = kWhiteColor;
        screenNameL.textColor = kWhiteColor;
        timeL.textColor = kWhiteColor;
        textAL.textColor = kWhiteColor;
    } else if (self.style == HSUStatusViewStyle_Light) {
        attrI.hidden = YES;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    // set frames
    CGFloat cw = self.width;
    ambientArea.frame = ccr(0, 0, cw, ambient_S);
    ambientI.frame = ccr(avatar_S-ambient_S, (ambient_H-ambient_S)/2, ambient_S, ambient_S);
    ambientL.frame = ccr(avatar_S+padding_S, 0, cw-ambientI.right-padding_S, ambient_H);
    
    if (ambientArea.hidden) {
        avatarI.frame = ccr(avatarI.left, 0, avatar_S, avatar_S);
    } else {
        avatarI.frame = ccr(avatarI.left, ambientArea.bottom, avatar_S, avatar_S);
    }
    
    infoArea.frame = ccr(ambientL.left, avatarI.top, cw-ambientL.left, info_H);
    textAL.frame = ccr(ambientL.left, infoArea.bottom, infoArea.width, [self.data.renderData[@"text_height"] floatValue] + 3);
    
    [timeL sizeToFit];
    timeL.frame = ccr(infoArea.width-timeL.width, -1, timeL.width, timeL.height);
    
    [attrI sizeToFit];
    attrI.frame = ccr(timeL.left-attrI.width-3, -1, attrI.width, attrI.height);
    
    [nameL sizeToFit];
    nameL.frame = ccr(0, -3, MIN(attrI.left-3, nameL.width), nameL.height);
    
    [screenNameL sizeToFit];
    screenNameL.frame = ccr(nameL.right+3, -1, attrI.left-nameL.right, screenNameL.height);
}

- (void)setupWithData:(HSUTableCellData *)cellData
{
    self.data = cellData;
    
    NSDictionary *rawData = cellData.rawData;
    
    // ambient
    NSDictionary *retweetedStatus = rawData[@"retweeted_status"];
    ambientI.hidden = NO;
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
//    UIButton *b;
//    [b setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"ProfilePlaceholderOverBlue"]];
//    [b setImageWithURL:[NSURL URLWithString:avatarUrl] forState:UIControlStateHighlighted placeholderImage:[UIImage imageNamed:@"avatar_pressed"]];
    
    NSDictionary *geo = rawData[@"geo"];
    
    // attr
    attrI.imageName = nil;
    NSString *attrName = nil;
    if ([rawData[@"in_reply_to_status_id_str"] length]) {
        attrName = @"convo";
    } else if (entities) {
        NSArray *medias = entities[@"media"];
        NSArray *urls = entities[@"urls"];
        if (medias && medias.count) {
            NSDictionary *media = medias[0];
            NSString *type = media[@"type"];
            if ([type isEqualToString:@"photo"]) {
                attrName = @"photo";
            }
        } else if (urls && urls.count) {
            for (NSDictionary *urlDict in urls) {
                NSString *expandedUrl = urlDict[@"expanded_url"];
                attrName = [self _attrForUrl:expandedUrl];
                if (attrName) {
                    break;
                }
            }
        }
    } else if ([geo isKindOfClass:[NSDictionary class]]) {
        attrName = @"geo";
    }
    
    if (attrName) {
        attrI.imageName = S(@"ic_tweet_attr_%@_default", attrName);
        self.data.renderData[@"attr"] = attrName;
    } else {
        attrI.imageName = nil;
        [self.data.renderData removeObjectForKey:@"attr"];
    }
    
    
    // time
    NSDate *createdDate = [TWENGINE getDateFromTwitterCreatedAt:rawData[@"created_at"]];
    timeL.text = createdDate.twitterDisplay;
    
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
            if (self.style == HSUStatusViewStyle_Default) {
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
    }
    textAL.delegate = self;
}

- (NSString *)_attrForUrl:(NSString *)url
{
    if ([url hasPrefix:@"http://4sq.com"] ||
        [url hasPrefix:@"http://youtube.com"]) {
        return @"summary";
    } else if ([url hasPrefix:@"http://youtube.com"] ||
               [url hasPrefix:@"http://snpy.tv"]) {
        return @"video";
    } else if ([url hasPrefix:@"http://instagram.com"] || [url hasPrefix:@"http://instagr.am"]) {
        NSString *instagramAPIUrl = S(@"http://api.instagram.com/oembed?url=%@", url);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:instagramAPIUrl]];
        self.data.renderData[@"instagram_image_url"] = [NSNull null];
        AFHTTPRequestOperation *instagramer = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            if ([JSON isKindOfClass:[NSDictionary class]]) {
                NSString *imageUrl = JSON[@"url"];
                self.data.renderData[@"instagram_image_url"] = imageUrl;
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
        }];
        [instagramer start];
        return @"photo";
    }
    return nil;
}

+ (CGFloat)_textHeightWithCellData:(HSUTableCellData *)data constraintWidth:(CGFloat)constraintWidth
{
    NSDictionary *status = data.rawData;
    NSString *text = [status[@"text"] gtm_stringByUnescapingFromHTML];
    NSDictionary *entities = status[@"entities"];
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
    
//    CGFloat cellWidth = [HSUCommonTools winWidth] - margin_W * 2 - padding_S * 3 - avatar_S;
    CGFloat textHeight = [testSizeLabel sizeThatFits:ccs(constraintWidth, 0)].height;
    data.renderData[@"text_height"] = @(textHeight);
    return textHeight;
}

+ (CGFloat)heightForData:(HSUTableCellData *)data constraintWidth:(CGFloat)constraintWidth
{
    NSDictionary *rawData = data.rawData;
    
    CGFloat height = 0;
    CGFloat leftHeight = 0;
    
    if (rawData[@"retweeted_status"]) {
        height += ambient_H; // add ambient
        leftHeight += ambient_H;
    }
    height += info_H; // add info
    
    height += [self _textHeightWithCellData:data constraintWidth:constraintWidth-avatar_S-padding_S] + padding_S;
    
    leftHeight += avatar_S; // add avatar
    
    CGFloat cellHeight = MAX(height, leftHeight);
    cellHeight = floorf(cellHeight);
    
    return cellHeight;
}

#pragma mark - attributtedLabel delegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if (!url) {
        return ;
    }
    id attributedLabelDelegate = self.data.renderData[@"attributed_label_delegate"];
    [attributedLabelDelegate performSelector:@selector(attributedLabel:didSelectLinkWithArguments:) withObject:label withObject:@{@"url": url, @"cell_data": self.data}];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didReleaseLinkWithURL:(NSURL *)url
{
    if (!url) {
        return;
    }
    id attributedLabelDelegate = self.data.renderData[@"attributed_label_delegate"];
    [attributedLabelDelegate performSelector:@selector(attributedLabel:didReleaseLinkWithArguments:) withObject:label withObject:@{@"url": url, @"cell_data": self.data}];
}

@end
