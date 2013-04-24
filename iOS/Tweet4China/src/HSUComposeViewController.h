//
//  HSUComposeViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUComposeViewController : UIViewController

@property (nonatomic, copy) NSString *defaultText;
@property (nonatomic, copy) NSString *defaultTitle;
@property (nonatomic, assign) NSRange defaultSelectedRange;
@property (nonatomic, copy) NSString *inReplyToStatusId;

@end
