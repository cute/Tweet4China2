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
#import "NSString+URLEncoding.h"
#import "HSUStatusActionView.h"
#import "AFNetworking.h"

#define ambient_H 14
#define info_H 16
#define textAL_font_S 18
#define margin_W 10
#define padding_S 10
#define avatar_S 48
#define ambient_S 20
#define textAL_LHM 1.2
#define actionV_H 44
#define avatar_text_Distance 15
#define text_time_Distance 7
#define time_summary_Distance 20

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
    
    UIView *actionSeperatorV;
    HSUStatusActionView *actionV;
    
    UIImageView *imageView;
    UIActivityIndicatorView *imgLoadSpinner;
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
        textAL.font = [UIFont fontWithName:@"Georgia" size:textAL_font_S];
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
        
        imageView = [[UIImageView alloc] init];
        imageView.backgroundColor = bw(229);
        [contentArea addSubview:imageView];
        
        imgLoadSpinner = GRAY_INDICATOR;
        [imageView addSubview:imgLoadSpinner];
        
        // action buttons
        actionSeperatorV = [[UIView alloc] init];
        actionSeperatorV.backgroundColor = bw(226);
        [self.contentView addSubview:actionSeperatorV];
        
        actionV = [[HSUStatusActionView alloc] initWithStatus:self.data.rawData style:HSUStatusActionViewStyle_Default];
        [self.contentView addSubview:actionV];
        
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
    
    avatarI.leftTop = ccp(avatarI.left, ambientArea.hidden ? 0 : ambientArea.bottom);
    
    [nameL sizeToFit];
    nameL.leftTop = ccp(avatarI.right+padding_S, avatarI.top+7);
    
    [screenNameL sizeToFit];
    screenNameL.leftTop = ccp(nameL.left, nameL.bottom+3);
    
    textAL.frame = ccr(textAL.left, avatarI.bottom+avatar_text_Distance, textAL.width, [self.data.renderData[@"text_height"] floatValue]);
    
    [timeL sizeToFit];
    timeL.leftTop = ccp(textAL.left, textAL.bottom+text_time_Distance);
    
    imageView.top = timeL.bottom + time_summary_Distance;
    LF(@"%@", NSStringFromCGRect(imageView.frame));
    
    actionV.frame = ccr(0, 0, self.contentView.width, actionV_H);
    actionV.bottom = self.contentView.height;
    
    actionSeperatorV.frame = ccr(9, actionV.top-1, actionV.width-9*2, 1);
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
    NSDate *createdDate = [TWENGINE getDateFromTwitterCreatedAt:rawData[@"created_at"]];
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
        
        NSArray *userMentions = entities[@"user_mentions"];
        if (userMentions && userMentions.count) {
            for (NSDictionary *userMention in userMentions) {
                NSString *screenName = userMention[@"screen_name"];
                NSString *userUrl = S(@"user://%@", screenName);
                NSRange range = [text rangeOfString:S(@"@%@", screenName)];
                [textAL addLinkToURL:[NSURL URLWithString:userUrl] withRange:range];
            }
        }
        
        NSArray *hashTags = entities[@"hashtags"];
        if (hashTags && hashTags.count) {
            for (NSDictionary *hashTag in hashTags) {
                NSString *tag = hashTag[@"text"];
                NSString *userUrl = S(@"tag://%@", tag.URLEncodedString);
                NSRange range = [text rangeOfString:S(@"#%@", tag)];
                [textAL addLinkToURL:[NSURL URLWithString:userUrl] withRange:range];
            }
        }
    }
    textAL.delegate = self;
    
    if ([data.renderData[@"attr"] isEqualToString:@"photo"]) {
        imageView.width = [data.renderData[@"photo_fit_width"] floatValue];
        imageView.height = [data.renderData[@"photo_fit_height"] floatValue];
        imgLoadSpinner.center = imageView.boundsCenter;
        NSString *photoUrl = data.renderData[@"photo_url"];
        if (photoUrl) {
            [self _downloadPhotoWithURL:[NSURL URLWithString:data.renderData[@"photo_url"]]];
        } else {
            NSString *instagramUrl = data.renderData[@"instagram_url"];
            if (instagramUrl) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:instagramUrl]];
                AFHTTPRequestOperation *instagramer = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    if ([JSON isKindOfClass:[NSDictionary class]]) {
                        NSString *imageUrl = JSON[@"url"];
                        data.renderData[@"photo_url"] = imageUrl;
                        [self _downloadPhotoWithURL:[NSURL URLWithString:imageUrl]];
                    } else {
                        [imgLoadSpinner stopAnimating];
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    [imgLoadSpinner stopAnimating];
                }];
                [instagramer start];
                [imgLoadSpinner startAnimating];
            } else {
                [imgLoadSpinner stopAnimating];
            }
        }
    }
    
    // set action events
    [self setupControl:actionV.replayB forKey:@"reply"];
    [self setupControl:actionV.retweetB forKey:@"retweet"];
    [self setupControl:actionV.favoriteB forKey:@"favorite"];
    [self setupControl:actionV.moreB forKey:@"more"];
    [self setupControl:actionV.deleteB forKey:@"delete"];
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
        textAL.font = [UIFont fontWithName:@"Georgia" size:textAL_font_S];
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
    CGFloat textHeight = [testSizeLabel sizeThatFits:ccs(cellWidth, 0)].height + 3;
    data.renderData[@"text_height"] = @(textHeight);
    return textHeight;
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
    height += [self _textHeightWithCellData:data];
    height += text_time_Distance;
    
    // timeL height
    height += 20;
    height += text_time_Distance;
    
    // photo height
    [self _parseSummary:data];
    CGFloat summaryWidth = [data.renderData[@"photo_width"] floatValue];
    CGFloat summaryHeight = [data.renderData[@"photo_height"] floatValue];
    if (summaryHeight) {
        height += time_summary_Distance;
        CGFloat contentWidth = [HSUCommonTools winWidth] - padding_S * 4;
        if (summaryWidth > contentWidth) {
            summaryHeight = summaryHeight * contentWidth / summaryWidth;
            summaryWidth = contentWidth;
        } else {
            summaryHeight /= 2;
            summaryWidth /= 2;
        }
        height += summaryHeight;
        data.renderData[@"photo_fit_width"] = @(summaryWidth);
        data.renderData[@"photo_fit_height"] = @(summaryHeight);
    }
    
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

#pragma mark - attributtedLabel delegate
- (void)attributedLabelDidLongPressed:(TTTAttributedLabel *)label
{
    id attributedLabelDelegate = self.data.renderData[@"attributed_label_delegate"];
    [attributedLabelDelegate performSelector:@selector(attributedLabelDidLongPressed:) withObject:label];
}

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

- (void)_downloadPhotoWithURL:(NSURL *)photoURL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:photoURL];
    AFHTTPRequestOperation *downloader = [[AFImageRequestOperation alloc] initWithRequest:request];
    [downloader setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [imgLoadSpinner stopAnimating];
        [imageView setImage:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [imgLoadSpinner stopAnimating];
    }];
    [downloader start];
    [imgLoadSpinner startAnimating];
}

+ (void)_parseSummary:(HSUTableCellData *)data
{
    NSDictionary *entities = data.rawData[@"entities"];
    NSArray *urls = entities[@"urls"];
    NSArray *medias = entities[@"media"];
    NSString *attrName = nil;
    if (medias && medias.count) {
        NSDictionary *media = medias[0];
        NSString *type = media[@"type"];
        if ([type isEqualToString:@"photo"]) {
            attrName = @"photo";
            data.renderData[@"photo_url"] = media[@"media_url_https"];
            data.renderData[@"photo_width"] = media[@"sizes"][@"large"][@"w"];
            data.renderData[@"photo_height"] = media[@"sizes"][@"large"][@"h"];
        }
    } else if (urls && urls.count) {
        for (NSDictionary *urlDict in urls) {
            NSString *expandedUrl = urlDict[@"expanded_url"];
            if ([expandedUrl hasPrefix:@"http://4sq.com"] ||
                [expandedUrl hasPrefix:@"http://youtube.com"]) {
                attrName = @"summary";
            } else if ([expandedUrl hasPrefix:@"http://youtube.com"] ||
                       [expandedUrl hasPrefix:@"http://snpy.tv"]) {
                attrName = @"video";
            } else if ([expandedUrl hasPrefix:@"http://instagram.com"] || [expandedUrl hasPrefix:@"http://instagr.am"]) {
                NSString *instagramUrl = S(@"http://api.instagram.com/oembed?url=%@", expandedUrl);
                data.renderData[@"instagram_url"] = instagramUrl;
                data.renderData[@"photo_width"] = @(612);
                data.renderData[@"photo_height"] = @(612);
                attrName = @"photo";
            }
            if (attrName) {
                break;
            }
        }
    }
    
    data.renderData[@"attr"] = attrName;
}

@end
