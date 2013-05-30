//
//  HSUNavigationBarLight.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/29/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUNavigationBarLight.h"

@implementation HSUNavigationBarLight
{
    BOOL addedBackground;
}

- (void)layoutSubviews
{
    if (!addedBackground) {
        addedBackground = YES;
        [self setBackgroundImage:[UIImage imageNamed:@"bg_nav_bar_light"] forBarMetrics:UIBarMetricsDefault];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 44);
}

@end
