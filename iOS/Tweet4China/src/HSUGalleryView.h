//
//  HSUGalleryView.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUGalleryView : UIView

- (id)initWithStatus:(NSDictionary *)status imageURL:(NSURL *)imageURL;

- (void)showWithAnimation:(BOOL)animation;
- (void)hideWithAnimation:(BOOL)animation;

@end
