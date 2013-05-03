//
//  HSUProfileDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"

#define kAction_UserTimeline @"user_timeline"
#define kAction_Following @"following"
#define kAction_Followers @"followers"
#define kAction_Favorites @"favorites"
#define kAction_Lists @"lists"
#define kAction_Drafts @"drafts"

@interface HSUProfileDataSource : HSUBaseDataSource

@end
