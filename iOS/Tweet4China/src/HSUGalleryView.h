//
//  HSUGalleryView.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSUBaseViewController.h"

@interface HSUGalleryView : UIView

@property (nonatomic, weak) HSUBaseViewController *viewController;

- (id)initWithData:(HSUTableCellData *)data imageURL:(NSURL *)imageURL;

- (void)showWithAnimation:(BOOL)animation;
- (void)hideWithAnimation:(BOOL)animation;

@end
