//
//  HSUStatusViewController.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTweetsViewController.h"

@interface HSUStatusViewController : HSUTweetsViewController

- (id)initWithStatus:(NSDictionary *)status;

- (void)tappedPhoto:(UIImage *)image withCellData:(HSUTableCellData *)cellData;

@end
