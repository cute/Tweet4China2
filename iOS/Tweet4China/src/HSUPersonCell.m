//
//  HSUPersonCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUPersonCell.h"

@implementation HSUPersonCell
{
    UIButton *followButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        followButton = [[UIButton alloc] init];
    }
    return self;
}

- (void)setupWithData:(NSDictionary *)data
{
    [super setupWithData:data];
    
    [followButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self setupControl:followButton forKey:@"follow" withData:data];
}

@end
