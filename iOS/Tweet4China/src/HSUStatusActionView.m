//
//  HSUStatusActionView.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/27/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusActionView.h"

@implementation HSUStatusActionView
{
    BOOL isMyTweet;
}

- (id)initWithStatus:(NSDictionary *)status style:(HSUStatusActionViewStyle)style
{
    self = [super init];
    if (self) {
        isMyTweet = [status[@"user"][@"screen_name"] isEqualToString:TWENGINE.myScreenName];
        
        self.backgroundColor = kClearColor;
        
        // Reply
        UIButton *replayB = [[UIButton alloc] init];
        [self addSubview:replayB];
        self.replayB = replayB;
        replayB.showsTouchWhenHighlighted = YES;
        if (style == HSUStatusActionViewStyle_Default) {
            [replayB setImage:[UIImage imageNamed:@"icn_tweet_action_reply"] forState:UIControlStateNormal];
        } else if (style == HSUStatusActionViewStyle_Gallery) {
            [replayB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_reply_default"] forState:UIControlStateNormal];
        }
        [replayB sizeToFit];
        
        // Retweet
        BOOL retweeted = [status[@"retweeted"] boolValue];
        UIButton *retweetB = [[UIButton alloc] init];
        [self addSubview:retweetB];
        self.retweetB = retweetB;
        retweetB.showsTouchWhenHighlighted = YES;
        if (isMyTweet) {
            if (style == HSUStatusActionViewStyle_Default) {
                [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_disabled"] forState:UIControlStateNormal];
            } else if (style == HSUStatusActionViewStyle_Gallery) {
                [retweetB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_retweet_disabled"] forState:UIControlStateNormal];
            }
        } else if (retweeted) {
            if (style == HSUStatusActionViewStyle_Default) {
                [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_on"] forState:UIControlStateNormal];
            } else if (style == HSUStatusActionViewStyle_Gallery) {
                [retweetB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_retweet_on_default"] forState:UIControlStateNormal];
                [retweetB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_retweet_on_pressed"] forState:UIControlStateHighlighted];
            }
        } else {
            if (style == HSUStatusActionViewStyle_Default) {
                [retweetB setImage:[UIImage imageNamed:@"icn_tweet_action_retweet_off"] forState:UIControlStateNormal];
            } else if (style == HSUStatusActionViewStyle_Gallery) {
                [retweetB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_retweet_off_default"] forState:UIControlStateNormal];
                [retweetB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_retweet_off_pressed"] forState:UIControlStateHighlighted];
            }
        }
        [retweetB sizeToFit];
        
        // Favorite
        BOOL favorited = [status[@"favorited"] boolValue];
        UIButton *favoriteB = [[UIButton alloc] init];
        [self addSubview:favoriteB];
        self.favoriteB = favoriteB;
        favoriteB.showsTouchWhenHighlighted = YES;
        if (favorited) {
            if (style == HSUStatusActionViewStyle_Default) {
                [favoriteB setImage:[UIImage imageNamed:@"icn_tweet_action_favorite_on"] forState:UIControlStateNormal];
            } else if (style == HSUStatusActionViewStyle_Gallery) {
                [favoriteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_favorite_on_default"] forState:UIControlStateNormal];
                [favoriteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_favorite_on_pressed"] forState:UIControlStateHighlighted];
            }
        } else {
            if (style == HSUStatusActionViewStyle_Default) {
                [favoriteB setImage:[UIImage imageNamed:@"icn_tweet_action_favorite_off"] forState:UIControlStateNormal];
            } else if (style == HSUStatusActionViewStyle_Gallery) {
                [favoriteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_favorite_off_default"] forState:UIControlStateNormal];
                [favoriteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_favorite_off_pressed"] forState:UIControlStateHighlighted];
            }
        }
        [favoriteB sizeToFit];
        
        // More
        UIButton *moreB = [[UIButton alloc] init];
        [self addSubview:moreB];
        self.moreB = moreB;
        moreB.showsTouchWhenHighlighted = YES;
        if (style == HSUStatusActionViewStyle_Default) {
            [moreB setImage:[UIImage imageNamed:@"icn_tweet_action_more"] forState:UIControlStateNormal];
        } else if (style == HSUStatusActionViewStyle_Gallery) {
            [moreB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_more_default"] forState:UIControlStateNormal];
            [moreB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_more_pressed"] forState:UIControlStateHighlighted];
        }
        [moreB sizeToFit];
        
        // Delete
        UIButton *deleteB = [[UIButton alloc] init];
        [self addSubview:deleteB];
        self.deleteB = deleteB;
        deleteB.showsTouchWhenHighlighted = YES;
        if (style == HSUStatusActionViewStyle_Default) {
            [deleteB setImage:[UIImage imageNamed:@"icn_tweet_action_delete"] forState:UIControlStateNormal];
        } else if (style == HSUStatusActionViewStyle_Gallery) {
            [deleteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_delete_default"] forState:UIControlStateNormal];
            [deleteB setImage:[UIImage imageNamed:@"icn_gallery_tweet_action_delete_pressed"] forState:UIControlStateHighlighted];
        }
        [deleteB sizeToFit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSMutableArray *actionButtons = [NSMutableArray array];
    [actionButtons addObject:self.replayB];
    [actionButtons addObject:self.retweetB];
    [actionButtons addObject:self.favoriteB];
    [actionButtons addObject:self.moreB];
    if (isMyTweet) {
        [actionButtons addObject:self.deleteB];
        self.deleteB.hidden = NO;
    } else {
        self.deleteB.hidden = YES;
    }
    
    for (uint i=0; i<actionButtons.count; i++) {
        [actionButtons[i] setCenter:ccp(self.width / 2 / actionButtons.count * (2 * i + 1), self.height / 2)];
    }
}

@end
