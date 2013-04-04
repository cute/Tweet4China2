//
//  HSUNavitationBar.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUNavitationBar.h"
#import "HSUComposeViewController.h"

@implementation HSUNavitationBar
{
    UIImageView *logo;
}

- (void)layoutSubviews
{
    if (!logo) {
        logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_title_logo"]];
        [self addSubview:logo];
    }
    logo.frame = CGRectMake(self.bounds.size.width/2-logo.bounds.size.width/2, 10, logo.bounds.size.width, logo.bounds.size.height);
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

- (void)composeButtonTouched
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kHSUNotification_Compose object:self];
}

@end
