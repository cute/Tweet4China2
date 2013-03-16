//
//  UIImageView+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "UIImageView+Addition.h"

@implementation UIImageView (Addition)

- (NSString *)imageName
{
    return nil;
}

- (void)setImageName:(NSString *)imageName
{
    if (imageName) {
        self.image = [UIImage imageNamed:imageName];
    } else {
        self.image = nil;
    }
}

@end
