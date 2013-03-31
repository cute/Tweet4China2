//
//  UIView+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/24/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Addition)

@property (nonatomic, readwrite) CGFloat left, right, top, bottom, width, height;

- (NSString *)frameStr;

@end
