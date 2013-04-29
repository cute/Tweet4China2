//
//  UIViewController+Additions.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/29/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "UIViewController+Additions.h"

@implementation UIViewController (Additions)

- (CGRect)frame
{
    return self.view.frame;
}

- (void)setFrame:(CGRect)frame
{
    self.view.frame = frame;
}

- (CGSize)size
{
    return self.view.size;
}

- (void)setSize:(CGSize)size
{
    self.view.size = size;
}

- (CGFloat)width
{
    return self.view.width;
}

- (void)setWidth:(CGFloat)width
{
    self.view.width = width;
}

- (CGFloat)height
{
    return self.view.height;
}

- (void)setHeight:(CGFloat)height
{
    self.view.height = height;
}

- (CGFloat)left
{
    return self.view.left;
}

- (void)setLeft:(CGFloat)left
{
    self.view.left = left;
}

- (CGFloat)right
{
    return self.view.right;
}

- (void)setRight:(CGFloat)right
{
    self.view.right = right;
}

- (CGFloat)top
{
    return self.view.top;
}

- (void)setTop:(CGFloat)top
{
    self.view.top = top;
}

- (CGFloat)bottom
{
    return self.view.bottom;
}

- (void)setBottom:(CGFloat)bottom
{
    self.view.bottom = bottom;
}

@end
