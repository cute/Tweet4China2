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
    if (customSubviewsCreated) return;
    
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_title_logo"]];
    logo.center = self.center;
    logo.frame = CGRectMake(logo.frame.origin.x, 10, logo.frame.size.width, logo.frame.size.height);
    [self addSubview:logo];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage imageNamed:@"ic_title_search"] forState:UIControlStateNormal];
    [searchButton sizeToFit];
    searchButton.frame = CGRectMake(245, 12, searchButton.bounds.size.width, searchButton.bounds.size.height);
    searchButton.showsTouchWhenHighlighted = YES;
    [self addSubview:searchButton];
    
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tweetButton setImage:[UIImage imageNamed:@"ic_title_tweet"] forState:UIControlStateNormal];
    [tweetButton sizeToFit];
    tweetButton.frame = CGRectMake(286, 12, tweetButton.bounds.size.width, tweetButton.bounds.size.height);
    tweetButton.showsTouchWhenHighlighted = YES;
    [self addSubview:tweetButton];
    
    self.userInteractionEnabled = YES;
    customSubviewsCreated = YES;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rectangle = CGRectMake(0, 0, [HSUCommonTools winWidth], rect.size.height/2);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rectangle);
    rectangle = CGRectMake(0, rect.size.height/2, [HSUCommonTools winWidth], rect.size.height/2);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, rectangle);
    
    [[UIImage imageNamed:@"bg_nav_bar"] drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 47);
}
@end
