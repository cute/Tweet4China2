//
//  HSUNavitationBar.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "HSUNavitationBar.h"

@implementation HSUNavitationBar
{
    BOOL customSubviewsCreated;
}

- (void)layoutSubviews
{
    NSInteger logoTag = 1, tweetTag = 2, searchTag = 3;
    UIImageView *logo = nil;
    UIButton *tweetButton = nil;
    UIButton *searchButton = nil;
    
    if (!customSubviewsCreated) {
        logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_title_logo"]];
        logo.tag = logoTag;
        [self addSubview:logo];
        
        tweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tweetButton.tag = tweetTag;
        [tweetButton setImage:[UIImage imageNamed:@"ic_title_tweet"] forState:UIControlStateNormal];
        [tweetButton sizeToFit];
        tweetButton.showsTouchWhenHighlighted = YES;
        [self addSubview:tweetButton];
        
        searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        searchButton.tag = searchTag;
        [searchButton setImage:[UIImage imageNamed:@"ic_title_search"] forState:UIControlStateNormal];
        [searchButton sizeToFit];
        searchButton.showsTouchWhenHighlighted = YES;
        [self addSubview:searchButton];
        
        self.userInteractionEnabled = YES;
        customSubviewsCreated = YES;
    } else {
        logo = (UIImageView *)[self viewWithTag:logoTag];
        tweetButton = (UIButton *)[self viewWithTag:tweetTag];
        searchButton = (UIButton *)[self viewWithTag:searchTag];
    }
    
    logo.frame = CGRectMake(self.bounds.size.width/2-logo.bounds.size.width/2, 10, logo.bounds.size.width, logo.bounds.size.height);
    CGFloat right1 = [HSUCommonTools isIPhone] ? 10 : 14;
    CGFloat right2 = [HSUCommonTools isIPhone] ? 22 : 30;
    tweetButton.frame = CGRectMake([HSUCommonTools winWidth]-right1-tweetButton.bounds.size.width, 12, tweetButton.bounds.size.width, tweetButton.bounds.size.height);
    searchButton.frame = CGRectMake(tweetButton.frame.origin.x-right2-searchButton.bounds.size.width, 12, searchButton.bounds.size.width, searchButton.bounds.size.height);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rectangle = CGRectMake(0, 0, rect.size.width, rect.size.height/2);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rectangle);
    rectangle = CGRectMake(0, rect.size.height/2, rect.size.width, rect.size.height/2);
    CGContextSetRGBFillColor(context, .9, .9, .9, 1);
    CGContextSetRGBStrokeColor(context, .9, .9, .9, 1);
    CGContextFillRect(context, rectangle);
    
    [[UIImage imageNamed:@"bg_nav_bar"] drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 47);
}

@end
