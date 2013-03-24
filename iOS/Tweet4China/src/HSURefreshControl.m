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

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshing) name:kNNStartRefreshing object:nil];
    }
    return self;
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
