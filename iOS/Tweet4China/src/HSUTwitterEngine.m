//
//  FHSTwitterEngine+Addition.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTwitterEngine.h"
#import "OAuthConsumer.h"
#import "TwitterText.h"
#import "OAMutableURLRequest.h"

@implementation HSUTwitterEngine

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

+ (FHSTwitterEngine *)engine {
    static FHSTwitterEngine *staticEngine = nil;
    static dispatch_once_t pred;

    dispatch_once(&pred, ^{
        staticEngine = [[self alloc] initWithConsumerKey:kTwitterAppKey andSecret:kTwitterAppSecret];
        [staticEngine loadAccessToken];
    });

    return staticEngine;
}

- (void)auth {
    [self showOAuthLoginControllerFromViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (BOOL)dealWithError:(NSError *)error errTitle:(NSString *)errTitle {
    if (error == nil) return YES;
    if (![error isKindOfClass:[NSError class]]) {
        return YES;
    }
    L(error);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error.code == 401) {
            RIButtonItem *cancelBnt = [RIButtonItem itemWithLabel:@"Cancel"];
            RIButtonItem *confirmBnt = [RIButtonItem itemWithLabel:@"Sign in"];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errTitle message:error.localizedDescription cancelButtonItem:cancelBnt otherButtonItems:confirmBnt, nil];
            [alertView show];
            
            confirmBnt.action = ^{
                [TWENGINE auth];
            };

        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:errTitle message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    });
    return NO;
}

- (NSUInteger)twitterTextLength:(NSString *)text {
    return [TwitterText tweetLength:text];
}

- (OAMutableURLRequest *)requestWithBaseURL:(NSURL *)baseURL {
    OAConsumer *consumer = [[OAConsumer alloc]initWithKey:kTwitterAppKey secret:kTwitterAppSecret];
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:baseURL consumer:consumer token:self.accessToken realm:nil signatureProvider:nil];
    return request;
}

- (id)_getUsersByIDsReturnedValue:(id)idsReturenValue
{
    NSMutableArray *identifiersFromRequest = [NSMutableArray array];
    
    if ([idsReturenValue isKindOfClass:[NSDictionary class]]) {
        id idsRAW = [(NSDictionary *)idsReturenValue objectForKey:@"ids"];
        if ([idsRAW isKindOfClass:[NSArray class]]) {
            [identifiersFromRequest addObjectsFromArray:(NSArray *)idsRAW];
        }
    } else if ([idsReturenValue isKindOfClass:[NSError class]]) {
        return idsReturenValue;
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

- (id)getFriendsMoreThanID {
    return [self _getUsersByIDsReturnedValue:[self getFriendsIDs]];
}

- (id)getTrends {
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/trends/place.json"];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *idP = [OARequestParameter requestParameterWithName:@"id" value:@"1"];
    return [self sendGETRequest:request withParameters:[NSArray arrayWithObjects:idP, nil]];
}

- (NSString *)myScreenName
{
    NSDictionary *userSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey];
    if (userSettings) {
        return userSettings[@"screen_name"];
    }
    return nil;
}

- (NSError *)destroyTweet:(NSString *)identifier {
    NSString *urlString = S(@"https://api.twitter.com/1.1/statuses/destroy/%@.json", identifier);
    NSURL *baseURL = [NSURL URLWithString:urlString];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    return [self sendPOSTRequest:request withParameters:nil];
}

- (id)getFollowersSinceId:(NSString *)sinceId forUserScreenName:(NSString *)screenName
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *cursorParam = [OARequestParameter requestParameterWithName:@"cursor" value:sinceId?:@"-1"];
    OARequestParameter *screenNameParam = [OARequestParameter requestParameterWithName:@"screen_name" value:screenName];
    OARequestParameter *includeUserEntitiesParam = [OARequestParameter requestParameterWithName:@"include_user_entities" value:@"false"];
    return [self sendGETRequest:request withParameters:@[cursorParam, screenNameParam, includeUserEntitiesParam]];
}

- (id)getFollowingSinceId:(NSString *)sinceId forUserScreenName:(NSString *)screenName
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/list.json"];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *cursorParam = [OARequestParameter requestParameterWithName:@"cursor" value:sinceId?:@"-1"];
    OARequestParameter *screenNameParam = [OARequestParameter requestParameterWithName:@"screen_name" value:screenName];
    OARequestParameter *includeUserEntitiesParam = [OARequestParameter requestParameterWithName:@"include_user_entities" value:@"false"];
    OARequestParameter *skipStatusParam = [OARequestParameter requestParameterWithName:@"skip_status" value:@"true"];
    return [self sendGETRequest:request withParameters:@[cursorParam, screenNameParam, includeUserEntitiesParam, skipStatusParam]];
}

- (id)getDirectMessagesSinceID:(NSString *)sinceId
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/direct_messages.json"];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *cursorP = [OARequestParameter requestParameterWithName:@"since_id" value:sinceId?:@"-1"];
    OARequestParameter *countP = [OARequestParameter requestParameterWithName:@"count" value:@"200"];
    OARequestParameter *skipStatusP = [OARequestParameter requestParameterWithName:@"skip_status" value:@"true"];
    return [self sendGETRequest:request withParameters:[NSArray arrayWithObjects:cursorP, countP, skipStatusP, nil]];
}

- (id)getSentDirectMessagesSinceID:(NSString *)sinceId
{
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/direct_messages/sent.json"];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *cursorP = [OARequestParameter requestParameterWithName:@"since_id" value:sinceId?:@"-1"];
    OARequestParameter *countP = [OARequestParameter requestParameterWithName:@"count" value:@"200"];
    return [self sendGETRequest:request withParameters:[NSArray arrayWithObjects:cursorP, countP, nil]];
}

- (NSError *)sendDirectMessage:(NSString *)body toUser:(NSString *)user isID:(BOOL)isID {
    static NSString * const url_direct_messages_new = @"https://api.twitter.com/1.1/direct_messages/new.json";
    NSURL *baseURL = [NSURL URLWithString:url_direct_messages_new];
    OAMutableURLRequest *request = [OAMutableURLRequest requestWithURL:baseURL consumer:self.consumer token:self.accessToken];
    OARequestParameter *bodyP = [OARequestParameter requestParameterWithName:@"text" value:[body fhs_trimForTwitter]];
    OARequestParameter *userP = [OARequestParameter requestParameterWithName:isID?@"user_id":@"screen_name" value:user];
    return [self responseForSendPOSTRequest:request withParameters:[NSArray arrayWithObjects:userP, bodyP, nil]];
}

- (NSError *)responseForSendPOSTRequest:(OAMutableURLRequest *)request withParameters:(NSArray *)params
{
    
    if (![self isAuthorized]) {
        return [NSError errorWithDomain:@"You are not authorized via OAuth" code:401 userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
    }
    
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [request setTimeoutInterval:25];
    [request setHTTPMethod:@"POST"];
    [request setParameters:params];
    [request prepare];
    
    if (self.shouldClearConsumer) {
        self.shouldClearConsumer = NO;
        self.consumer = nil;
    }
    
    
    id retobj = [self sendRequest:request];
    
    if (retobj == nil) {
        return [NSError errorWithDomain:@"Twitter successfully processed the request, but did not return any content" code:204 userInfo:nil];
    }
    
    if ([retobj isKindOfClass:[NSError class]]) {
        return retobj;
    }
    
    id parsedJSONResponse = removeNull([NSJSONSerialization JSONObjectWithData:(NSData *)retobj options:NSJSONReadingMutableContainers error:nil]);
    
    if ([parsedJSONResponse isKindOfClass:[NSDictionary class]]) {
        NSString *errorMessage = [parsedJSONResponse objectForKey:@"error"];
        NSArray *errorArray = [parsedJSONResponse objectForKey:@"errors"];
        if (errorMessage.length > 0) {
            return [NSError errorWithDomain:errorMessage code:[[parsedJSONResponse objectForKey:@"code"]intValue] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
        } else if (errorArray.count > 0) {
            if (errorArray.count > 1) {
                return [NSError errorWithDomain:@"Multiple Errors" code:1337 userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
            } else {
                NSDictionary *theError = [errorArray objectAtIndex:0];
                return [NSError errorWithDomain:[theError objectForKey:@"message"] code:[[theError objectForKey:@"code"]integerValue] userInfo:[NSDictionary dictionaryWithObject:request forKey:@"request"]];
            }
        }
    }
    
    return parsedJSONResponse;
}

@end
