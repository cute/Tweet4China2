//
//  UIView+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Additions)

@property (nonatomic, readwrite) CGFloat left, right, top, bottom, width, height;
@property (nonatomic, readwrite) CGPoint topCenter, bottomCenter, leftCenter, rightCenter;
@property (nonatomic, readwrite) CGPoint leftTop, leftBottom, rightTop, rightBottom;
@property (nonatomic, readonly) CGPoint boundsCenter;
@property (nonatomic, readwrite) CGSize size;

- (NSString *)frameStr;

@end
