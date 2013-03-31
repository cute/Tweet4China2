//
//  UIView+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    self.frame = ccr(left, self.top, self.width, self.height);
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    self.frame = ccr(right-self.width, self.top, self.width, self.height);
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    self.frame = ccr(self.left, top, self.width, self.height);
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    self.frame = ccr(self.left, self.top, self.width, bottom-self.height);
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    self.frame = ccr(self.left, self.top, width, self.height);
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    self.frame = ccr(self.left, self.top, self.width, height);
}

- (NSString *)frameStr
{
    return NSStringFromCGRect(self.frame);
}

@end
