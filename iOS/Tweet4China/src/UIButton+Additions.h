//
//  UIButton+Additions.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/5/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UIButton (Additions)

@property(nonatomic, assign) UIEdgeInsets hitTestEdgeInsets;

- (void)setTapTarget:(id)target action:(SEL)action;

@end