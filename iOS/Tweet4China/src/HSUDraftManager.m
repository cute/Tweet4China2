//
//  HSUDraftManager.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUDraftManager.h"
#import "NSString+MD5.h"

@implementation HSUDraftManager

+ (id)shared
{
    static dispatch_once_t onceQueue;
    static HSUDraftManager *hSUDraftManager = nil;
    
    dispatch_once(&onceQueue, ^{ hSUDraftManager = [[self alloc] init]; });
    return hSUDraftManager;
}

- (NSString *)saveDraftWithStatus:(NSString *)status imageFilePath:(NSString *)imageFilePath reply:(NSString *)reply locationXY:(CLLocationCoordinate2D)locationXY
{
    NSString *draftID = [status MD5Hash];
    NSDictionary *drafts = [[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"];
    if (!drafts) {
        drafts = [[NSMutableDictionary alloc] init];
    } else {
        NSDictionary *draft = drafts[draftID];
        if (draft) {
            return draftID;
        } else {
            drafts = [drafts mutableCopy];
        }
    }
    ((NSMutableDictionary *)drafts)[draftID] = @{@"status": status,
                                                 @"image_file_path": imageFilePath,
                                                 @"in_reply_to_status_id": reply,
                                                 @"lat": [@(locationXY.latitude) description],
                                                 @"long": [@(locationXY.longitude) description],
                                                 @"update_time": @([[NSDate date] timeIntervalSince1970]),
                                                 };
    [[NSUserDefaults standardUserDefaults] setObject:drafts forKey:@"drafts"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return draftID;
}

- (NSString *)saveDraftWithStatus:(NSString *)status imageData:(NSData *)imageData reply:(NSString *)reply locationXY:(CLLocationCoordinate2D)locationXY
{
    NSString *filePath = dp(S(@"drafts/%@", imageData.md5));
    [imageData writeToFile:filePath atomically:YES];
    return [self saveDraftWithStatus:status imageFilePath:filePath reply:reply locationXY:locationXY];
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

- (void)removeDraftWithID:(NSString *)draftID
{
    NSMutableDictionary *drafts = [[[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"] mutableCopy];
    if (drafts) {
        [drafts removeObjectForKey:draftID];
        [[NSUserDefaults standardUserDefaults] setObject:drafts forKey:@"drafts"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSArray *)draftsSortedByUpdateTime
{
    NSDictionary *drafts = [[NSUserDefaults standardUserDefaults] objectForKey:@"drafts"];
    NSMutableArray *draftArr = [[NSMutableArray alloc] initWithCapacity:drafts.count];
    for (NSString *dID in drafts.allKeys) {
        NSDictionary *draft = drafts[dID];
        if ([draft[@"active"][@"active"] boolValue]) {
            [draftArr addObject:draft];
        }
    }
    [draftArr sortUsingComparator:^NSComparisonResult(NSDictionary *d1, NSDictionary *d2) {
        return [d1[@"update_time"] doubleValue] - [d2[@"update_time"] doubleValue];
    }];
    return draftArr;
}

@end
