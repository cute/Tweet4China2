//
//  HSUCommonTools.h
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#define RM CGRectMake

#import <Foundation/Foundation.h>

@interface HSUCommonTools : NSObject

+ (BOOL)isIPhone;
+ (BOOL)isIPad;
+ (CGFloat)winWidth;
+ (CGFloat)winHeight;

+ (void)sendMailWithSubject:(NSString *)subject body:(NSString *)body presentFromViewController:(UIViewController *)viewController;

@end
