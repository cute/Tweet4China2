//
//  FHSTwitterEngine+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine+Addition.h"
#import "OAuthConsumer.h"

@implementation FHSTwitterEngine (Addition)

- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    OAConsumer *consumer = [[OAConsumer alloc]initWithKey:kTwitterAppKey secret:kTwitterAppSecret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc]initWithURL:baseURL consumer:consumer token:self.accessToken realm:nil signatureProvider:nil];
    
    OARequestParameter *max_id = [OARequestParameter requestParameterWithName:@"max_id" value:maxId];
    OARequestParameter *countParam = [OARequestParameter requestParameterWithName:@"count" value:[NSString stringWithFormat:@"%d", count]];
    
    NSArray *params = [NSArray arrayWithObjects:max_id, countParam, nil];
    
    return [self sendGETRequest:request withParameters:params];
}

@end
