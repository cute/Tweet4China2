//
//  FHSTwitterEngine+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine.h"

@class OAMutableURLRequest;

@interface HSUTwitterEngine : FHSTwitterEngine

@property (nonatomic, strong) OAConsumer *consumer;
@property (nonatomic, copy, readonly) NSString *myScreenName;

+ (HSUTwitterEngine *)engine;
- (void)auth;
// YES if no error
- (BOOL)dealWithError:(NSError *)error errTitle:(NSString *)errTitle;
- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count;
- (NSUInteger)twitterTextLength:(NSString *)text;
- (OAMutableURLRequest *)requestWithBaseURL:(NSURL *)baseURL;

- (id)getFriendsMoreThanID;
- (id)getTrends;
- (id)getFollowersSinceId:(NSString *)sinceId forUserScreenName:(NSString *)screenName;
- (id)getFollowingSinceId:(NSString *)sinceId forUserScreenName:(NSString *)screenName;
- (id)getDirectMessagesSinceID:(NSString *)sinceId;
- (id)getSentDirectMessagesSinceID:(NSString *)sinceId;

- (NSArray *)generateRequestStringsFromArray:(NSArray *)array;



// super
@property (assign, nonatomic) BOOL shouldClearConsumer;

- (id)sendRequest:(NSURLRequest *)request;
- (NSError *)sendPOSTRequest:(OAMutableURLRequest *)request withParameters:(NSArray *)params;

@end
