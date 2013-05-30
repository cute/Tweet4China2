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
        [self setBackgroundImage:[UIImage imageNamed:@"bg_nav_bar"] forBarMetrics:UIBarMetricsDefault];
    }
    logo.frame = CGRectMake(self.bounds.size.width/2-logo.bounds.size.width/2, 10, logo.bounds.size.width, logo.bounds.size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.frame.size.width, 44);
}

@end
