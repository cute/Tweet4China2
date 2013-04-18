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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startRefreshing) name:kNNStartRefreshing object:nil];
    }
    return self;
}

- (void)startRefreshing
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"psst1" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

- (void)endRefreshing
{
    [super endRefreshing];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"pop" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound(soundID);
}

@end
