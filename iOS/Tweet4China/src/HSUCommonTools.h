//
//  HSUCommonTools.h
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

void notification_add_observer(NSString *name, id observer, SEL selector);
void notification_remove_observer(id observer);
void notification_post(NSString *name);
void notification_post_with_object(NSString *name, id object);

@interface HSUCommonTools : NSObject

+ (BOOL)isIPhone;
+ (BOOL)isIPad;
+ (CGFloat)winWidth;
+ (CGFloat)winHeight;

+ (void)sendMailWithSubject:(NSString *)subject body:(NSString *)body presentFromViewController:(UIViewController *)viewController;

@end
