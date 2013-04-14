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

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    [self setupControl:followButton forKey:@"follow" withData:data cleanOldEvents:YES];
}

@end
