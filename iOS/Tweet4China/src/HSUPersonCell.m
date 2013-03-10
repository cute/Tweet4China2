//
//  HSUPersonCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUPersonCell.h"

@implementation HSUPersonCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setupWithData:(NSDictionary *)data atIndex:(NSInteger)index
{
    [super setupWithData:data atIndex:index];
    UIButton *followButton = [[UIButton alloc] init];
    followButton.tag = index;
    [self setupControl:followButton forKey:@"follow" withData:data];
}

@end
