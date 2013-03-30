//
//  HSUDefinitions.h
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#ifndef Tweet4China_HSUDefinitions_h
#define Tweet4China_HSUDefinitions_h

// Define Proxy Url
// Deploy the proxy program on your host before this.
// You can find the scripts for the server side in directory Tweet4China/Server/.
// If you do not define here, the App will ask for your input at the first time.
//#define PROXY_URL

// Define twitter application consumer key & secret.
// Access level of your twitter application should contains Read, write, and direct messages
// if you want to use all of the features.
#define kTwitterAppKey
#define kTwitterAppSecret

#define kTabBarHeight 44
#define kIPadTabBarWidth 84

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define dp(filename) [([NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]) stringByAppendingPathComponent:filename]
#define tp(filename) [([NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0])stringByAppendingPathComponent:filename]
#define ccr(x, y, w, h) CGRectMake(x, y, w, h)
#define ccp(x, y) CGPointMake(x, y)
#define ccs(w, h) CGSizeMake(w, h)
#define edi(top, left, bottom, right) UIEdgeInsetsMake(top, left, bottom, right)
#define cgrgba(r, g, b, a) [[UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a] CGColor]
#define cgrgb(r, g, b) [[UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1] CGColor]
#define rgba(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define rgb(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1]
#define bw(v) [UIColor colorWithWhite:w alpha:1]
#define L(s) NSLog(@"%@", s);
#define LR(rect) NSLog(@"%@", NSStringFromCGRect(rect));
#define LF(f,...) NSLog(f,##__VA_ARGS__);
#define S(f,...) [NSString stringWithFormat:f,##__VA_ARGS__]
#define kBlackColor [UIColor blackColor]
#define kWhiteColor [UIColor whiteColor]
#define kClearColor [UIColor clearColor]
#define kWinWidth [HSUCommonTools winWidth]
#define kWinHeight [HSUCommonTools winHeight]
#define kStrechedImage(imageName, capWidth, capHeight) [[UIImage imageNamed:imageName] stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight]

#define kNNStartRefreshing @"HSU_Start_Refreshing"

#import "HSUTableCellData.h"
#import "HSUUIEvent.h"
#import "HSUCommonTools.h"
#import "UIView+Addition.h"

#define kDataType_Status @"Status"
#define kDataType_LoadMore @"LoadMore"


#define kHSUNotification_Compose (@"HSUNotification_Compose")

#endif