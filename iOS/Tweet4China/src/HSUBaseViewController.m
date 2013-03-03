//
//  HSUBaseViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import "HSUBaseViewController.h"
#import "HSUTexturedView.h"
#import <QuartzCore/QuartzCore.h>

@interface HSUBaseViewController ()

@end

@implementation HSUBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UIImage *texture = [UIImage imageNamed:@"bg_texture"];
    UIView *background = [[HSUTexturedView alloc] initWithFrame:self.view.bounds texture:texture];
    [self.view addSubview:background];
}

@end
