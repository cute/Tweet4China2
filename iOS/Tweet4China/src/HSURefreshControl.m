//
//  HSURefreshControl.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSURefreshControl.h"
#import <AVFoundation/AVFoundation.h>

@implementation HSURefreshControl
{
    AVAudioPlayer *beginRefreshingPlayer, *endRefreshingPlayer;
}

- (void)beginRefreshing
{
    [super beginRefreshing];
    
    if (beginRefreshingPlayer == nil) {
        beginRefreshingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"psst1" withExtension:@"wav"] error:nil];
    }
    [beginRefreshingPlayer play];
}

- (void)endRefreshing
{
    [super endRefreshing];
    
    if (endRefreshingPlayer == nil) {
        endRefreshingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"pop" withExtension:@"wav"] error:nil];
    }
    [endRefreshingPlayer play];
}

@end
