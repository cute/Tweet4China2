//
//  FHSTwitterEngine+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine+Addition.h"
#import "OAuthConsumer.h"
#import "TwitterText.h"

@implementation FHSTwitterEngine (Addition)

- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    OAConsumer *consumer = [[OAConsumer alloc]initWithKey:kTwitterAppKey secret:kTwitterAppSecret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc]initWithURL:baseURL consumer:consumer token:self.accessToken realm:nil signatureProvider:nil];
    
    OARequestParameter *countParam = [OARequestParameter requestParameterWithName:@"count" value:[NSString stringWithFormat:@"%d", count]];
    
    if (!maxId) {
        NSArray *params = [NSArray arrayWithObjects:countParam, nil];
        return [self sendGETRequest:request withParameters:params];
    } else {
        OARequestParameter *max_id = [OARequestParameter requestParameterWithName:@"max_id" value:maxId];
        NSArray *params = [NSArray arrayWithObjects:max_id, countParam, nil];
        return [self sendGETRequest:request withParameters:params];
    }
}

+ (id)engine {
    static FHSTwitterEngine *staticEngine = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        staticEngine = [[self alloc] initWithConsumerKey:kTwitterAppKey andSecret:kTwitterAppSecret];
        [staticEngine loadAccessToken];
    });

    return staticEngine;
 }

+ (void)auth {
    [[self engine] showOAuthLoginControllerFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (void)dealWithError:(NSError *)error errTitle:(NSString *)errTitle {
    if (error == nil) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.code == 401) {
            RIButtonItem *cancelBnt = [RIButtonItem itemWithLabel:@"Cancel"];
            RIButtonItem *confirmBnt = [RIButtonItem itemWithLabel:@"Sign in"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errTitle message:error.localizedDescription cancelButtonItem:cancelBnt otherButtonItems:confirmBnt, nil];
            [alertView show];

            confirmBnt.action = ^{
                [self auth];
            };

        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errTitle message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    });
}

+ (NSUInteger)twitterTextLength:(NSString *)text {
    return [TwitterText tweetLength:text];
}

@end
