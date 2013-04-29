//
//  HSUNavigationBarLight.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/29/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUNavigationBarLight.h"

@implementation HSUNavigationBarLight

- (void)drawRect:(CGRect)rect
{
//    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rectangle = CGRectMake(0, 0, rect.size.width, rect.size.height/2);
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, rectangle);
    rectangle = CGRectMake(0, rect.size.height/2, rect.size.width, rect.size.height/2);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1);
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
    CGContextFillRect(context, rectangle);
    
    [[UIImage imageNamed:@"bg_nav_bar_light"] drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 47);
}

@end
