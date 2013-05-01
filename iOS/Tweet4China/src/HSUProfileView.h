//
//  HSUProfileView.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUProfileView : UIView <UIScrollViewDelegate>

- (id)initWithScreenName:(NSString *)screenName;

- (void)setupWithProfile:(NSDictionary *)profile;

@end
