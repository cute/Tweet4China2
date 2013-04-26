//
//  HSUGalleryVC.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUGalleryVC.h"

@interface HSUGalleryVC ()

@end

@implementation HSUGalleryVC

- (id)initWithStatus:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        L(status);
        NSArray *medias = status[@"entities"][@"media"];
        if (medias && medias.count) {
            NSDictionary *media = medias[0];
            NSString *type = media[@"type"];
            if ([type isEqualToString:@"photo"]) {
                NSString *url = media[@"url"];
                L(url);
            }
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBlackColor;
    self.view.alpha = 0;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(_fireTapGesture)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:.5 animations:^{
        self.view.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)_fireTapGesture
{
    [UIView animateWithDuration:.5 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
    }];
}

@end
