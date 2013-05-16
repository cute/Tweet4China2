//
//  HSUDraftManager.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUDraftManager.h"
#import "NSString+MD5.h"
#import "HSUDraftsViewController.h"
#import "OARequestParameter.h"

@implementation HSUDraftManager

+ (id)shared
{
    static dispatch_once_t onceQueue;
    static HSUDraftManager *hSUDraftManager = nil;
    
    dispatch_once(&onceQueue, ^{ hSUDraftManager = [[self alloc] init]; });
    return hSUDraftManager;
}

- (NSDictionary *)saveDraftWithTitle:(NSString *)title status:(NSString *)status imageFilePath:(NSString *)imageFilePath reply:(NSString *)reply locationXY:(CLLocationCoordinate2D)locationXY
{
    NSString *draftID = [status MD5Hash];
    NSDictionary *drafts = [[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"];
    if (!drafts) {
        drafts = [[NSMutableDictionary alloc] init];
    } else {
        drafts = [drafts mutableCopy];
    }
    NSMutableDictionary *draft = [[NSMutableDictionary alloc] init];
    draft[@"status"] = status;
    draft[@"id"] = draftID;
    if (title) draft[@"title"] = title;
    if (imageFilePath) draft[@"image_file_path"] = imageFilePath;
    if (reply) draft[kTwitter_Parameter_Key_Reply_ID] = reply;
    if (locationXY.latitude) draft[@"lat"] = S(@"%g", locationXY.latitude);
    if (locationXY.longitude) draft[@"long"] = S(@"%g", locationXY.longitude);
    draft[@"update_time"] = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]];
    ((NSMutableDictionary *)drafts)[draftID] = draft;
    [[NSUserDefaults standardUserDefaults] setObject:drafts forKey:@"drafts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return draft;
}

- (NSDictionary *)saveDraftWithTitle:(NSString *)title status:(NSString *)status imageData:(NSData *)imageData reply:(NSString *)reply locationXY:(CLLocationCoordinate2D)locationXY
{
    NSString *filePath = nil;
    if (imageData) {
        NSString *filePath = dp(S(@"drafts/%@", imageData.md5));
        [imageData writeToFile:filePath atomically:YES];
    }
    return [self saveDraftWithTitle:title status:status imageFilePath:filePath reply:reply locationXY:locationXY];
}


- (void)activeDraft:(NSDictionary *)draft
{
    [self activeDraftWithID:draft[@"id"]];
}

- (void)activeDraftWithID:(NSString *)draftID
{
    NSMutableDictionary *drafts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"] mutableCopy];
    NSMutableDictionary *draft = [drafts[draftID] mutableCopy];
    draft[@"active"] = @(YES);
    drafts[draftID] = draft;
    [[NSUserDefaults standardUserDefaults] setObject:drafts forKey:@"drafts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)removeDraft:(NSDictionary *)draft
{
    NSString *draftID = draft[@"id"];
    if (!draftID) {
        draftID = [draft[@"status"] MD5Hash];
    }
    return [self removeDraftWithID:draftID];
}

- (BOOL)removeDraftWithID:(NSString *)draftID
{
    if (!draftID) {
        return NO;
    }
    NSMutableDictionary *drafts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"] mutableCopy];
    if (drafts) {
        [drafts removeObjectForKey:draftID];
        [[NSUserDefaults standardUserDefaults] setObject:drafts forKey:@"drafts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return YES;
}

- (NSArray *)draftsSortedByUpdateTime
{
    NSDictionary *drafts = [[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"];
    NSMutableArray *draftArr = [[NSMutableArray alloc] initWithCapacity:drafts.count];
    for (NSString *dID in drafts.allKeys) {
        NSDictionary *draft = drafts[dID];
        if ([draft[@"active"] boolValue]) {
            [draftArr addObject:draft];
        }
    }
    [draftArr sortUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
        return [d1[@"update_time"] doubleValue] - [d2[@"update_time"] doubleValue];
    }];
    return draftArr;
}

- (void)presentDraftsViewController
{
    UINavigationController *nav = DEF_NavitationController_Light;
    nav.viewControllers = @[[[HSUDraftsViewController alloc] init]];
    [[HSUAppDelegate shared].tabController presentViewController:nav animated:YES completion:nil];
}

- (NSError *)sendDraft:(NSDictionary *)draft
{
    // do send
    NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    
    NSMutableArray *params = [NSMutableArray array];
    
    // status param
    OARequestParameter *statusP = [OARequestParameter requestParameterWithName:@"status" value:draft[@"status"]];
    [params addObject:statusP];
    
    // reply param
    if (draft[kTwitter_Parameter_Key_Reply_ID]) {
        OARequestParameter *inReplyToStatusIdP = [OARequestParameter requestParameterWithName:kTwitter_Parameter_Key_Reply_ID value:draft[kTwitter_Parameter_Key_Reply_ID]];
        [params addObject:inReplyToStatusIdP];
    }
    
    // image param
    if (draft[@"image_file_path"]) {
        baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
        NSData *imageData = [NSData dataWithContentsOfFile:draft[@"image_file_path"]];
        OARequestParameter *mediaP = [OARequestParameter requestParameterWithName:@"media_data[]" value:[imageData base64EncodingWithLineLength:0]];
        [params addObject:mediaP];
    }
    
    // location param
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake([draft[@"lat"] doubleValue], [draft[@"long"] doubleValue]);
    if (location.latitude && location.longitude) {
        OARequestParameter *latP = [OARequestParameter requestParameterWithName:@"lat" value:S(@"%g", location.latitude)];
        OARequestParameter *longP = [OARequestParameter requestParameterWithName:@"long" value:S(@"%g", location.longitude)];
        [params addObject:latP];
        [params addObject:longP];
    }
    
    OAMutableURLRequest *request = [TWENGINE requestWithBaseURL:baseURL];
    return [TWENGINE sendPOSTRequest:request withParameters:params];
}

@end
