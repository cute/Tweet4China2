//
//  HSUSendBarButtonItem.m
//  Tweet4China
//
//  Created by Jason Hsu on 13/5/28.
//  Copyright (c) 2013年 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUSendBarButtonItem.h"

@implementation HSUSendBarButtonItem

- (id)init
{
    self = [super init];
    if (self) {
        self.tintColor = bw(220);
        NSDictionary *attributes = @{UITextAttributeTextColor: kWhiteColor,
                                     UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:ccs(0, -1)]};
        NSDictionary *disabledAttributes = @{UITextAttributeTextColor: bw(129),
                                             UITextAttributeTextShadowColor: kWhiteColor,
                                             UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:ccs(0, 1)]};
        [self setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [self setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
        [self setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    if (self.enabled != enabled) {
        self.tintColor = enabled ? rgb(52, 172, 232) : bw(220);
    }
    
    [super setEnabled:enabled];
}

@end
