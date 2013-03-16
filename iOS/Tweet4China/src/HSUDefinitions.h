//
//  HSUDefinitions.h
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#ifndef Tweet4China_HSUDefinitions_h
#define Tweet4China_HSUDefinitions_h

#define kTwitterAppKey @"ykNHjkGVh91pu38dzlzE1A"
#define kTwitterAppSecret @"KYUnIUjcSupeLb4I0z4VEihpMbvGZj5310g5dYYY0g"

#define kTabBarHeight 44
#define kIPadTabBarWidth 84

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define ccr(x, y, w, h) CGRectMake(x, y, w, h)
#define ccp(x, y) CGPointMake(x, y)
#define ccs(w, h) CGSizeMake(w, h)

#endif