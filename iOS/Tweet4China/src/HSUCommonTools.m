//
//  HSUCommonTools.m
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "HSUCommonTools.h"

void notification_add_observer(NSString *name, id observer, SEL selector)
{
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:name object:nil];
}

void notification_remove_observer(id observer)
{
    [[NSNotificationCenter defaultCenter] removeObserver:observer];
}

void notification_post(NSString *name)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

void notification_post_with_object(NSString *name, id object)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
}


@interface HSUMailHelper : NSObject <MFMailComposeViewControllerDelegate>
@property (nonatomic, weak) UIViewController *currentViewController;

- (void)sendMailWithSubject:(NSString *)subject body:(NSString *)body presentFromViewController:(UIViewController *)viewController;

+ (HSUMailHelper *)getInstance;

@end

@implementation HSUMailHelper

static HSUMailHelper *mailHelper;
+ (HSUMailHelper *)getInstance
{
    if (!mailHelper) {
        mailHelper = [[HSUMailHelper alloc] init];
    }
    return mailHelper;
}

- (void)sendMailWithSubject:(NSString *)subject body:(NSString *)body presentFromViewController:(UIViewController *)viewController
{
    self.currentViewController = viewController;
    
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;
        [mailCont setSubject:subject];
        [mailCont setMessageBody:body isHTML:YES];
        [viewController presentViewController:mailCont animated:YES completion:^{}];
    } else {
        NSString *url = [NSString stringWithFormat:@"mailto:?subject=%@&body=%@",
                         [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self.currentViewController dismissViewControllerAnimated:YES completion:^{
        mailHelper = nil;
    }];
}

@end

@implementation HSUCommonTools

+ (BOOL)isIPhone
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

+ (BOOL)isIPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (CGFloat)winWidth
{
    return [HSUCommonTools isIPhone] ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.width - kIPadTabBarWidth;
}

+ (CGFloat)winHeight
{
    return [[UIScreen mainScreen] bounds].size.height;
}

+ (void)sendMailWithSubject:(NSString *)subject body:(NSString *)body presentFromViewController:(UIViewController *)viewController
{
    [[HSUMailHelper getInstance] sendMailWithSubject:subject body:body presentFromViewController:viewController];
}

@end
