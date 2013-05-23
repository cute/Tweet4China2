//
//  HSUProfileView.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSUProfileViewDelegate;
@interface HSUProfileView : UIView <UIScrollViewDelegate>

- (id)initWithScreenName:(NSString *)screenName delegate:(id<HSUProfileViewDelegate>)delegate;

- (void)setupWithProfile:(NSDictionary *)profile;

@end

@protocol HSUProfileViewDelegate <NSObject>

- (void)tweetsButtonTouched;
- (void)followingButtonTouched;
- (void)followersButtonTouched;
- (void)actionsButtonTouched;
- (void)followButtonTouched:(UIButton *)followButton;
- (void)messagesButtonTouched;

@end