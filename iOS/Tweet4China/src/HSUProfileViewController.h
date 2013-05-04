//
//  HSUProfileViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 2/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTweetsViewController.h"

@interface HSUProfileViewController : HSUTweetsViewController

@property (nonatomic, copy) NSString *screenName;

- (id)initWithScreenName:(NSString *)screenName;

@end
