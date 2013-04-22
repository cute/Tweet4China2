//
//  FHSTwitterEngine+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine.h"

@class OAMutableURLRequest;

@interface FHSTwitterEngine (Additions)

@property (strong, nonatomic) OAConsumer *consumer;

+ (FHSTwitterEngine *)engine;
- (void)auth;
// YES if no error
- (BOOL)dealWithError:(NSError *)error errTitle:(NSString *)errTitle;
- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count;
- (NSUInteger)twitterTextLength:(NSString *)text;
- (OAMutableURLRequest *)requestWithBaseURL:(NSURL *)baseURL;

- (id)getFriendsMoreThanID;
- (id)getTrends;

- (NSArray *)generateRequestStringsFromArray:(NSArray *)array;

@end
