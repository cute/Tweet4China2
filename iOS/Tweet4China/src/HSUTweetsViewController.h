//
//  HSUTweetsViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/3/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseViewController.h"

@interface HSUTweetsViewController : HSUBaseViewController

- (void)reply:(HSUTableCellData *)cellData;
- (void)retweet:(HSUTableCellData *)cellData;
- (void)favorite:(HSUTableCellData *)cellData;
- (void)more:(HSUTableCellData *)cellData;

- (void)openPhotoURL:(NSURL *)photoURL withCellData:(HSUTableCellData *)cellData;
- (void)openWebURL:(NSURL *)webURL withCellData:(HSUTableCellData *)cellData;

@end
