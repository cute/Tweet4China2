//
//  HSUMiniBrowser.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/29/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUMiniBrowser : UIViewController

- (id)initWithURL:(NSURL *)url cellData:(HSUTableCellData *)cellData;

@property (nonatomic, weak) UIViewController *viewController;

@end
