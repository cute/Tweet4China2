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
- (NSString *)saveDraftWithTitle:(NSString *)title
                          status:(NSString *)status
                    imageFilePath:(NSString *)imageFilePath
                            reply:(NSString *)reply
                       locationXY:(CLLocationCoordinate2D)locationXY;

- (NSString *)saveDraftWithTitle:(NSString *)title
                          status:(NSString *)status
                        imageData:(NSData *)imageData
                            reply:(NSString *)reply
                       locationXY:(CLLocationCoordinate2D)locationXY;


- (void)activeDraftWithID:(NSString *)draftID;
- (void)removeDraftWithID:(NSString *)draftID;

- (NSArray *)draftsSortedByUpdateTime;

- (void)presentDraftsViewController;

@end
