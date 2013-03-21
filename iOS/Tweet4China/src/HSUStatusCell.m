//
//  HSUStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusCell.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Addition.h"
#import <QuartzCore/QuartzCore.h>

#define ambient_H 21
#define info_H 16
#define font_S 13
#define margin_W 10
#define padding_S 10
#define avatar_S 48
#define ambient_S 20

#define retweeted_R @"ic_ambient_retweet"
#define avatarPlaceholder_R @"avatar_pressed"
#define attr_photo_R @"ic_tweet_attr_photo_default"

@implementation HSUStatusCell
{
    UIView *background;
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
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        background = [[UIView alloc] init];
        background.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:background];
        background.backgroundColor = kClearColor;
        
        contentArea = [[UIView alloc] init];
        contentArea.translatesAutoresizingMaskIntoConstraints = NO;
        [background addSubview:contentArea];
        
        ambientArea = [[UIView alloc] init];
        ambientArea.translatesAutoresizingMaskIntoConstraints = NO;
        [contentArea addSubview:ambientArea];
        
        infoArea = [[UIView alloc] init];
        infoArea.translatesAutoresizingMaskIntoConstraints = NO;
        [contentArea addSubview:infoArea];
        
        ambientI = [[UIImageView alloc] init];
        ambientI.translatesAutoresizingMaskIntoConstraints = NO;
        [ambientArea addSubview:ambientI];
        
        ambientL = [[UILabel alloc] init];
        ambientL.translatesAutoresizingMaskIntoConstraints = NO;
        [ambientArea addSubview:ambientL];
        ambientL.font = [UIFont systemFontOfSize:font_S];
        ambientL.textColor = [UIColor grayColor];
        ambientL.highlightedTextColor = kWhiteColor;
        ambientL.backgroundColor = kClearColor;
        
        avatarI = [[UIImageView alloc] init];
        avatarI.translatesAutoresizingMaskIntoConstraints = NO;
        [contentArea addSubview:avatarI];
        avatarI.layer.cornerRadius = 5;
        avatarI.layer.masksToBounds = YES;
        
        nameL = [[UILabel alloc] init];
        nameL.translatesAutoresizingMaskIntoConstraints = NO;
        [infoArea addSubview:nameL];
        nameL.font = [UIFont boldSystemFontOfSize:14];
        nameL.textColor = [UIColor blackColor];
        nameL.highlightedTextColor = kWhiteColor;
        nameL.backgroundColor = kClearColor;
        
        screenNameL = [[UILabel alloc] init];
        screenNameL.translatesAutoresizingMaskIntoConstraints = NO;
        [infoArea addSubview:screenNameL];
        screenNameL.font = [UIFont systemFontOfSize:12];
        screenNameL.textColor = [UIColor grayColor];
        screenNameL.highlightedTextColor = kWhiteColor;
        screenNameL.backgroundColor = kClearColor;
        
        attrI = [[UIImageView alloc] init];
        attrI.translatesAutoresizingMaskIntoConstraints = NO;
        [infoArea addSubview:attrI];
        
        timeL = [[UILabel alloc] init];
        timeL.translatesAutoresizingMaskIntoConstraints = NO;
        [infoArea addSubview:timeL];
        timeL.font = [UIFont systemFontOfSize:11];
        timeL.textColor = [UIColor grayColor];
        timeL.highlightedTextColor = kWhiteColor;
        timeL.backgroundColor = kClearColor;
        
        textAL = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        textAL.translatesAutoresizingMaskIntoConstraints = NO;
        [contentArea addSubview:textAL];
        textAL.font = [UIFont systemFontOfSize:14];
        textAL.textColor = [UIColor blackColor];
        textAL.highlightedTextColor = kWhiteColor;
        textAL.lineBreakMode = NSLineBreakByWordWrapping;
        textAL.numberOfLines = 0;
        textAL.linkAttributes = @{(NSString *)kCTUnderlineStyleAttributeName: @(NO),
                                  (NSString *)kCTForegroundColorAttributeName: (id)cgc(30, 98, 164, 1)};
        textAL.activeLinkAttributes = @{(NSString *)kTTTBackgroundFillColorAttributeName: (id)cgc(215, 230, 242, 1),
                                        (NSString *)kTTTBackgroundCornerRadiusAttributeName: @(2)};
        textAL.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        textAL.lineHeightMultiple = 1.2;
        textAL.backgroundColor = kClearColor;
        
        NSDictionary *vs;
        NSString *vf;
        NSArray *cs;
        
        vs = NSDictionaryOfVariableBindings(background);
        vf = [NSString stringWithFormat:@"|-0-[background]-0-|"];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [self.contentView addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(background);
        vf = [NSString stringWithFormat:@"V:|-0-[background]-0-|"];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [self.contentView addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(contentArea);
        vf = [NSString stringWithFormat:@"|-%d-[contentArea]-%d-|", padding_S, padding_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [background addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(contentArea);
        vf = [NSString stringWithFormat:@"V:|-%d-[contentArea]-%d-|", padding_S, padding_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [background addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(ambientArea);
        vf = [NSString stringWithFormat:@"|-0-[ambientArea]-0-|"];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(ambientI, ambientL);
        vf = [NSString stringWithFormat:@"|-%d-[ambientI]-%d-[ambientL]-(>=0)-|", (avatar_S - ambient_S), padding_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:NSLayoutFormatAlignAllCenterY metrics:nil views:vs];
        [ambientArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(infoArea);
        vf = [NSString stringWithFormat:@"|-%d-[infoArea]-0-|", (avatar_S + padding_S)];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(nameL, screenNameL, attrI, timeL);
        vf = [NSString stringWithFormat:@"|-0-[nameL]-3-[screenNameL]-(>=3)-[attrI]-3-[timeL]-0-|"];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:NSLayoutFormatAlignAllCenterY metrics:nil views:vs];
        [infoArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(avatarI);
        vf = [NSString stringWithFormat:@"V:[avatarI(%d)]", avatar_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(avatarI);
        vf = [NSString stringWithFormat:@"|-0-[avatarI(%d)]", avatar_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(ambientArea);
        vf = [NSString stringWithFormat:@"V:|-0-[ambientArea(%d)]", ambient_H];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        ambientAreaConstraints = cs;
        
        vs = NSDictionaryOfVariableBindings(ambientArea, avatarI);
        vf = [NSString stringWithFormat:@"V:[ambientArea]-3-[avatarI(%d)]", avatar_S];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
        
        vs = NSDictionaryOfVariableBindings(ambientArea, infoArea);
        vf = [NSString stringWithFormat:@"V:[ambientArea]-0-[infoArea]"];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:vf options:0 metrics:nil views:vs];
        [contentArea addConstraints:cs];
    }
    return self;
}


- (void)setupWithData:(NSMutableDictionary *)data
{
    [super setupWithData:data];
    
    NSDictionary *cellData = data[@"cell_data"];
    NSMutableDictionary *renderData = data[@"render_data"];
    
    // ambient
    ambientI.hidden = NO;
    NSDictionary *retweetedStatus = cellData[@"retweeted_status"];
    if (retweetedStatus) {
        ambientI.imageName = retweeted_R;
        [ambientI sizeToFit];
        NSString *ambientText = [NSString stringWithFormat:@"%@ retweeted", cellData[@"user"][@"name"]];
        ambientL.text = ambientText;
        [ambientL sizeToFit];
        ambientArea.hidden = NO;
        [contentArea addConstraints:ambientAreaConstraints];
    } else {
        ambientI.imageName = nil;
        ambientL.text = nil;
        ambientArea.hidden = YES;
        ambientArea.bounds = CGRectZero;
        [contentArea removeConstraints:ambientAreaConstraints];
    }
    
    // avatar
    NSString *avatarUrl = cellData[@"user"][@"profile_image_url_https"];
    [avatarI setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:avatarPlaceholder_R]];
    
    // info
    nameL.text = cellData[@"user"][@"name"];
    [nameL sizeToFit];
    screenNameL.text = [NSString stringWithFormat:@"@%@", cellData[@"user"][@"screen_name"]];
    [screenNameL sizeToFit];
    attrI.imageName = nil;
    [attrI sizeToFit];
    NSArray *medias = cellData[@"entities"][@"media"];
    if (medias && medias.count) {
        NSDictionary *media = medias[0];
        NSString *type = media[@"type"];
        if ([type isEqualToString:@"photo"]) {
            attrI.imageName = attr_photo_R;
        }
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"eee MMM dd HH:mm:ss ZZZZ yyyy"]; // "Thu Mar 14 14:54:18 +0000 2013"
    NSDate *createdDate = [df dateFromString:cellData[@"created_at"]];
    createdDate = [df dateFromString:@"Wed Mar 20 10:44:33 +0000 2013"];
    timeL.text = createdDate.twitterDisplay;
    [timeL sizeToFit];
    
    // text
    NSAttributedString *attributedText = renderData[@"attributedText"];
    if (attributedText) {
        textAL.attributedText = attributedText;
    } else {
        NSString *text = cellData[@"text"];
        textAL.text = text;
        NSDictionary *entities = cellData[@"entities"];
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
        renderData[@"attributedText"] = textAL.attributedText;
    }
}

+ (CGFloat)heightForData:(NSMutableDictionary *)data
{
    NSDictionary *cellData = data[@"cell_data"];
    NSMutableDictionary *renderData = data[@"render_data"];
    if (renderData) {
        if (renderData[@"height"]) {
            return [renderData[@"height"] floatValue];
        }
    }
    
    CGFloat height = 0;
    CGFloat leftHeight = 0;
    
    height += padding_S; // add padding top
    leftHeight += padding_S;
    
    if (cellData[@"retweeted_status"]) {
        height += ambient_H; // add ambient
        leftHeight += ambient_H;
    }
    height += info_H; // add info
    
    NSString *text = cellData[@"text"];
    NSDictionary *entities = cellData[@"entities"];
    if (entities) {
        NSArray *urls = entities[@"urls"];
        if (urls && urls.count) {
            for (NSDictionary *urlDict in urls) {
                NSString *url = urlDict[@"url"];
                NSString *displayUrl = urlDict[@"display_url"];
                text = [text stringByReplacingOccurrencesOfString:url withString:displayUrl];
            }
        }
    }
    CGFloat cellWidth = [HSUCommonTools winWidth] - margin_W * 2 - padding_S - avatar_S;
    height += ceilf([text sizeWithFont:[UIFont systemFontOfSize:font_S] constrainedToSize:CGSizeMake(cellWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height); // add text
    
    height += padding_S; // add padding-bottom
    leftHeight += padding_S;
    
    leftHeight += avatar_S;
    
    CGFloat cellHeight = MAX(height, leftHeight) * 1.2;
    renderData[@"height"] = @(cellHeight);
    
    return cellHeight;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    textAL.frame = ccr((padding_S+avatar_S), info_H+(ambientArea.hidden ? 0 : ambient_H), self.bounds.size.width-(margin_W*2+padding_S*3+avatar_S), self.bounds.size.height-(padding_S*2+info_H+(ambientArea.hidden ? 0 : ambient_H)));
}

- (TTTAttributedLabel *)contentLabel
{
    return textAL;
}

@end
