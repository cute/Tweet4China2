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
#import "GTMNSString+HTML.h"
#import "UIButton+WebCache.h"

#define ambient_H 14
#define info_H 16
#define textAL_font_S 14
#define margin_W 10
#define padding_S 10
#define avatar_S 48
#define ambient_S 20
#define textAL_LHM 1.3

#define retweeted_R @"ic_ambient_retweet"
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
    UIImageView *flagIV;

    UIView *actionV;
    UIButton *replayB, *retweetB, *favoriteB, *moreB, *deleteB;
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

        flagIV = [[UIImageView alloc] init];
        [self.contentView addSubview:flagIV];

        // set frames
        contentArea.frame = ccr(padding_S, padding_S, self.contentView.width-padding_S*4, 0);
        CGFloat cw = contentArea.width;
        ambientArea.frame = ccr(0, 0, cw, ambient_H);
        ambientI.frame = ccr(avatar_S-ambient_S, (ambient_H-ambient_S)/2, ambient_S, ambient_S);
        ambientL.frame = ccr(avatar_S+padding_S, 0, cw-ambientI.right-padding_S, ambient_H);
        avatarI.frame = ccr(0, 0, avatar_S, avatar_S);
        infoArea.frame = ccr(ambientL.left, 0, cw-ambientL.left, info_H);
        attrI.frame = ccr(0, 0, 0, 16);
        textAL.frame = ccr(ambientL.left, 0, infoArea.width, 0);

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
    
    contentArea.frame = ccr(contentArea.left, contentArea.top, contentArea.width, self.contentView.height-padding_S*2);
    ambientArea.frame = ccr(0, 0, contentArea.width, ambient_S);
    
    if (ambientArea.hidden) {
        avatarI.frame = ccr(avatarI.left, 0, avatarI.width, avatarI.height);
    } else {
        avatarI.frame = ccr(avatarI.left, ambientArea.bottom, avatarI.width, avatarI.height);
    }
    
    infoArea.frame = ccr(infoArea.left, avatarI.top, infoArea.width, infoArea.height);
    textAL.frame = ccr(textAL.left, infoArea.bottom, textAL.width, [self.data.renderData[@"text_height"] floatValue] + 3);
    
    [timeL sizeToFit];
    timeL.frame = ccr(infoArea.width-timeL.width, -1, timeL.width, timeL.height);
    
    [attrI sizeToFit];
    attrI.frame = ccr(timeL.left-attrI.width-3, -1, attrI.width, attrI.height);
    
    [nameL sizeToFit];
    nameL.frame = ccr(0, -3, MIN(attrI.left-3, nameL.width), nameL.height);
    
    [screenNameL sizeToFit];
    screenNameL.frame = ccr(nameL.right+3, -1, attrI.left-nameL.right, screenNameL.height);

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
                attrName = [self.class attrForUrl:expandedUrl];
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
    } else {
        attrI.imageName = nil;
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
    
    self.contentView.backgroundColor = kClearColor;
    contentArea.alpha = 1;
    actionV.hidden = YES;
    self.data.renderData[@"mode"] = @"default";
}

+ (CGFloat)_textHeightWithCellData:(HSUTableCellData *)data
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
    
    CGFloat cellWidth = [HSUCommonTools winWidth] - margin_W * 2 - padding_S * 3 - avatar_S;
    CGFloat textHeight = [testSizeLabel sizeThatFits:ccs(cellWidth, 0)].height;
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
    CGFloat leftHeight = 0;
    
    height += padding_S; // add padding top
    leftHeight += padding_S;
    
    if (rawData[@"retweeted_status"]) {
        height += ambient_H; // add ambient
        leftHeight += ambient_H;
    }
    height += info_H; // add info

    height += [self _textHeightWithCellData:data] + padding_S;
    
    leftHeight += avatar_S; // add avatar
    
    height += padding_S; // add padding-bottom
    leftHeight += padding_S;
    
    CGFloat cellHeight = MAX(height, leftHeight);
    cellHeight = floorf(cellHeight);
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

- (void)cellSwiped:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self switchMode];
    }
}
- (void)switchMode {
    if (!actionV) { // set to default
        actionV = [[UIView alloc] init];
        UIImage *actionBG = [UIImage imageNamed:@"bg_swipe_tile"];
        UIColor *actionBGC = [UIColor colorWithPatternImage:actionBG];
        actionV.backgroundColor = actionBGC;

        replayB = [[UIButton alloc] init];
        replayB.showsTouchWhenHighlighted = YES;
        [replayB setImage:[UIImage imageNamed:@"icn_tweet_action_reply"] forState:UIControlStateNormal];
        [replayB sizeToFit];
        [actionV addSubview:replayB];

        retweetB = [[UIButton alloc] init];
        retweetB.showsTouchWhenHighlighted = YES;
        if ([self isMyTweet]) {
            [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_disabled"] forState:UIControlStateNormal];
        } else if (retweeted) {
            [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_on"] forState:UIControlStateNormal];
        } else {
            [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_off"] forState:UIControlStateNormal];
        }
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
        
        deleteB = [[UIButton alloc] init];
        deleteB.showsTouchWhenHighlighted = YES;
        [deleteB setImage:[UIImage imageNamed:@"icn_tweet_action_delete"] forState:UIControlStateNormal];
        [deleteB sizeToFit];
        [actionV addSubview:deleteB];

        [self.contentView addSubview:actionV];
        actionV.hidden = YES;
    }

    if (actionV.hidden) { // to action mode
        NSMutableArray *actionButtons = [NSMutableArray array];
        [self setupControl:replayB forKey:@"reply" withData:self.data cleanOldEvents:YES];
        [actionButtons addObject:replayB];
        [self setupControl:retweetB forKey:@"retweet" withData:self.data cleanOldEvents:YES];
        [actionButtons addObject:retweetB];
        [self setupControl:favoriteB forKey:@"favorite" withData:self.data cleanOldEvents:YES];
        [actionButtons addObject:favoriteB];
        [self setupControl:moreB forKey:@"more" withData:self.data cleanOldEvents:YES];
        [actionButtons addObject:moreB];
        if ([self isMyTweet]) {
            [self setupControl:deleteB forKey:@"delete" withData:self.data cleanOldEvents:YES];
            [actionButtons addObject:deleteB];
            deleteB.hidden = NO;
        } else {
            deleteB.hidden = YES;
        }
        
        actionV.frame = self.contentView.bounds;
        for (uint i=0; i<actionButtons.count; i++) {
            [actionButtons[i] setCenter:ccp(actionV.width / 2 / actionButtons.count * (2 * i + 1), actionV.height / 2)];
        }
        
        actionV.alpha = 0;
        actionV.hidden = NO;

        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.backgroundColor = bw(230);
            contentArea.alpha = 0;
            actionV.alpha = 1;
        }];

        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_HSUStatusCell_OtherCellSwiped object:self];
        self.data.renderData[@"mode"] = @"action";

    } else { // to default mode
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.backgroundColor = kClearColor;
            contentArea.alpha = 1;
            actionV.alpha = 0;
        } completion:^(BOOL finish){
            actionV.hidden = YES;
        }];
        self.data.renderData[@"mode"] = @"default";
    }
}

- (void)otherCellSwiped:(NSNotification *)notification {
    if (notification.object != self) {
        if (actionV && !actionV.hidden) {
            [self switchMode];
        }
    }
}

- (BOOL)isMyTweet {
    return [self.data.rawData[@"user"][@"screen_name"] isEqualToString:TWENGINE.myScreenName];
}

@end
