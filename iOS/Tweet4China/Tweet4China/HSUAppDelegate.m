//
//  HSUAppDelegate.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/27/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUAppDelegate.h"
#import "HSUProxyURLProtocol.h"
#import "HSUTabController.h"

@implementation HSUAppDelegate

+ (HSUAppDelegate *)shared
{
    return (HSUAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifndef NO_PROXY
    [NSURLProtocol registerClass:[HSUProxyURLProtocol class]];
#endif
    
    // Init global variables
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor blackColor];
    HSUTabController *tabController = [[HSUTabController alloc] init];
    self.window.rootViewController = tabController;
    self.tabController = tabController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
