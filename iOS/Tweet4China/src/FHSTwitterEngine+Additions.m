//
//  FHSTwitterEngine+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine+Additions.h"
#import "OAuthConsumer.h"
#import "TwitterText.h"
#import "OAMutableURLRequest.h"

@implementation FHSTwitterEngine (Additions)

@dynamic consumer;

- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
//    OAConsumer *consumer = [[OAConsumer alloc]initWithKey:kTwitterAppKey secret:kTwitterAppSecret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc]initWithURL:baseURL consumer:self.consumer token:self.accessToken realm:nil signatureProvider:nil];
    
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

- (OAMutableURLRequest *)requestWithBaseURL:(NSURL *)baseURL {
    OAConsumer *consumer = [[OAConsumer alloc]initWithKey:kTwitterAppKey secret:kTwitterAppSecret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:baseURL consumer:consumer token:self.accessToken realm:nil signatureProvider:nil];
    return request;
}

- (id)getFriendsMoreThanID {
    id returnedValue = [self getFriendsIDs];

    NSMutableArray *identifiersFromRequest = [NSMutableArray array];

    if ([returnedValue isKindOfClass:[NSDictionary class]]) {
        id idsRAW = [(NSDictionary *)returnedValue objectForKey:@"ids"];
        if ([idsRAW isKindOfClass:[NSArray class]]) {
            [identifiersFromRequest addObjectsFromArray:(NSArray *)idsRAW];
        }
    } else if ([returnedValue isKindOfClass:[NSError class]]) {
        return returnedValue;
    }

    if (identifiersFromRequest.count == 0) {
        return nil;
    }

    NSMutableArray *users = [NSMutableArray array];

    NSArray *usernameListStrings = [self generateRequestStringsFromArray:identifiersFromRequest];

    for (NSString *idListString in usernameListStrings) {
        NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/users/lookup.json"];
        OAMutableURLRequest *requestTwo = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
        NSMutableArray *params = [NSMutableArray array];
        
        OARequestParameter *iden = [OARequestParameter requestParameterWithName:@"user_id" value:idListString];
        [params addObject:iden];
        
        OARequestParameter *includeEntitiesP = [OARequestParameter requestParameterWithName:@"include_entities" value:@"false"];
        [params addObject:includeEntitiesP];
        
//        if (keywords && keywords.length) {
//            OARequestParameter *screenNameP = [OARequestParameter requestParameterWithName:@"screen_name" value:keywords];
//            [params addObject:screenNameP];
//        }

        id parsed = [self sendGETRequest:requestTwo withParameters:params];

        if ([parsed isKindOfClass:[NSDictionary class]]) {

            [users addObject:@{@"name": parsed[@"name"],
                    @"screen_name": parsed[@"screen_name"],
                    @"profile_image_url_https": parsed[@"profile_image_url_https"]}];

        } else if ([parsed isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dict in (NSArray *)parsed) {

                [users addObject:@{@"name": dict[@"name"],
                        @"screen_name": dict[@"screen_name"],
                        @"profile_image_url_https": dict[@"profile_image_url_https"]}];

            }
        } else if ([parsed isKindOfClass:[NSError class]]) {
            return parsed;
        }
    }
    
    [users sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *sn1 = obj1[@"screen_name"];
        NSString *sn2 = obj2[@"screen_name"];
        return [sn1 compare:sn2];
    }];
    
    return users;
}

@end
