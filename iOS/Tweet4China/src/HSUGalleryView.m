//
//  HSUGalleryView.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUGalleryView.h"
#import "AFNetworking.h"
#import "HSUStatusActionView.h"
#import "HSUStatusView.h"
#import "HSUStatusViewController.h"

@interface HSUGalleryView()

@end

@implementation HSUGalleryView
{
    UIProgressView *progressBar;
    UIImageView *imageView;
    UIView *menuView;
    HSUStatusView *statusView;
    HSUStatusActionView *actionView;
    
    CGFloat menuStartTop;
    CGFloat startTouchY;
    
    HSUTableCellData *cellData;
}

- (id)initWithData:(HSUTableCellData *)data imageURL:(NSURL *)imageURL
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
        cellData = data;
        
        self.backgroundColor = kBlackColor;
        self.alpha = 0;
        
        // subviews
        progressBar = [[UIProgressView alloc] init];
        [self addSubview:progressBar];
        progressBar.width = 250;
        progressBar.progressViewStyle = UIProgressViewStyleBar;
        progressBar.progressTintColor = kWhiteColor;
        progressBar.trackTintColor = kBlackColor;
        
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        menuView = [[UIView alloc] init];
        [self addSubview:menuView];
        menuView.backgroundColor = kBlackColor;
        menuView.alpha = 0.8;
        
        UIView *border = [[UIView alloc] init];
        [menuView addSubview:border];
        border.backgroundColor = bwa(255, 0.1);
        
        UIImageView *gripperView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_photo_detail_gripper"]];
        [menuView addSubview:gripperView];
        
        CGFloat statusHeight = [HSUStatusView heightForData:data
                                            constraintWidth:self.width-20];
        statusView = [[HSUStatusView alloc] initWithFrame:ccr(0, 0, self.width-20, statusHeight)
                                                    style:HSUStatusViewStyle_Gallery];
        [menuView addSubview:statusView];
        statusView.backgroundColor = kClearColor;
        [statusView setupWithData:data];
        
        UIView *sep = [[UIView alloc] init];
        [menuView addSubview:sep];
        sep.backgroundColor = bwa(255, .15);
        
        actionView = [[HSUStatusActionView alloc] initWithStatus:data.rawData style:HSUStatusActionViewStyle_Gallery];
        [menuView addSubview:actionView];
        
        [actionView.replayB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionView.retweetB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionView.favoriteB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionView.moreB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
        [actionView.deleteB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
        
        // set frames
        sep.size = ccs(self.width-10, 1);
        actionView.size = ccs(self.width, 38);
        menuView.size = ccs(self.width, 0);
        menuView.top = self.height - 17;
        
        border.frame = ccr(0, 1, menuView.width, 1);
        gripperView.topCenter = ccp(menuView.width/2, border.bottom+2);
        statusView.topCenter = ccp(gripperView.bottomCenter.x, gripperView.bottomCenter.y+5);;
        sep.topCenter = statusView.bottomCenter;
        actionView.topCenter = sep.bottomCenter;
        menuView.height = actionView.bottom + 5;
        
        progressBar.center = self.boundsCenter;
        imageView.frame = self.bounds;
        
        // gestures
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(_fireTapGesture:)];
        [self addGestureRecognizer:tapGesture];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
        [longPressGesture addTarget:self action:@selector(_fireLongPressGesture:)];
        [self addGestureRecognizer:longPressGesture];
        
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] init];
        swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [swipeDownGesture addTarget:self action:@selector(_fireSwipeDownGesture:)];
        [self addGestureRecognizer:swipeDownGesture];
        
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] init];
        swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [swipeUpGesture addTarget:self action:@selector(_fireSwipeUpGesture:)];
        [self addGestureRecognizer:swipeUpGesture];
        
        // load image
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        AFHTTPRequestOperation *downloader = [[AFImageRequestOperation alloc] initWithRequest:request];
        [downloader setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            float progress = bytesRead*1.0/totalBytesRead;
            if (progressBar.progress < progress) {
                [progressBar setProgress:progress animated:YES];
            }
        }];
        [downloader setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            progressBar.hidden = YES;
            [imageView setImage:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            progressBar.hidden = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Load image failed" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }];
        [downloader start];
    }
    return self;
}

- (void)showWithAnimation:(BOOL)animation
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if (animation) {
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        self.alpha = 1;
    }
}

- (void)_fireTapGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        BOOL statusViewTapped = [gesture locationInView:self].y > menuView.top;
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (statusViewTapped && self.viewController) {
                HSUStatusViewController *statusVC = [[HSUStatusViewController alloc] initWithStatus:cellData.rawData];
                [self.viewController.navigationController pushViewController:statusVC animated:YES];
            }
        }];
    }
}

- (void)_fireLongPressGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([gesture locationInView:self].y > menuView.top) {
            return;
        }
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *saveItem = [RIButtonItem itemWithLabel:@"Save image"];
        saveItem.action = ^{
            UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
        };
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:saveItem, nil];
        [actionSheet showInView:self.window];
    }
}

- (void)_fireSwipeDownGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            menuView.top = self.height - 17;
        }];
    }
}

- (void)_fireSwipeUpGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            menuView.bottom = self.height;
        }];
    }
}

- (void)_fireAction:(id)sender
{
    UIEvent *event = nil;
    if (sender == actionView.replayB) {
        event = cellData.renderData[@"reply"];
    } else if (sender == actionView.retweetB) {
        event = cellData.renderData[@"retweet"];
    } else if (sender == actionView.favoriteB) {
        event = cellData.renderData[@"favorite"];
    } else if (sender == actionView.moreB) {
        event = cellData.renderData[@"more"];
    } else if (sender == actionView.deleteB) {
        event = cellData.renderData[@"delete"];
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [UIView animateWithDuration:.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [event performSelector:@selector(fire:) withObject:sender];
    }];
}

@end
