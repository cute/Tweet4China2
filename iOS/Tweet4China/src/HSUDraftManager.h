//
//  HSUDraftManager.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HSUDraftManager : NSObject

+ (id)shared;

/**
 * return a draft id, md5-hashed by status
**/
- (NSDictionary *)saveDraftWithDraftID:(NSString *)draftID
                                 title:(NSString *)title
                                status:(NSString *)status
                         imageFilePath:(NSString *)imageFilePath
                                 reply:(NSString *)reply
                            locationXY:(CLLocationCoordinate2D)locationXY;

- (NSDictionary *)saveDraftWithDraftID:(NSString *)draftID
                                 title:(NSString *)title
                                status:(NSString *)status
                             imageData:(NSData *)imageData
                                 reply:(NSString *)reply
                            locationXY:(CLLocationCoordinate2D)locationXY;


- (void)activeDraft:(NSDictionary *)draft;
- (BOOL)removeDraft:(NSDictionary *)draft;

- (NSArray *)draftsSortedByUpdateTime;

- (void)presentDraftsViewController;

- (NSError *)sendDraft:(NSDictionary *)draft;

@end
