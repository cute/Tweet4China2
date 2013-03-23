//
//  HSUUIEvent.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUUIEvent.h"

@implementation HSUUIEvent

- (id)initWithName:(NSString *)name target:(id)target action:(SEL)action events:(UIControlEvents)events
{
    self = [super init];
    if (self) {
        self.name = name;
        self.target = target;
        self.action = action;
        self.events = events;
    }
    return self;
}

- (void)fire:(id)sender
{
    SuppressPerformSelectorLeakWarning(
        [self.target performSelector:self.action withObject:self.cellData];
    );
}

@end
