//
//  HSUTexturedView.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "HSUTexturedView.h"

@implementation HSUTexturedView

- (id)initWithFrame:(CGRect)frame texture:(UIImage *)texture
{
    self = [super initWithFrame:frame];
    if (self) {
        self.texture = texture;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGSize ts = self.texture.size;
    for (int i=0; i<rect.size.width/ts.width+1; i++) {
        for (int j=0; j<rect.size.height/ts.height+1; j++) {
            CGRect curRect = CGRectMake(i*ts.width, j*ts.height, ts.width, ts.height);
            [self.texture drawInRect:curRect];
        }
    }
}

@end
