//
//  HSUGalleryView.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUGalleryView.h"
#import "AFNetworking.h"
#import "HSUStatusActionView.h"
#import "HSUStatusView.h"

@implementation HSUGalleryView
{
    UIProgressView *progressBar;
    UIImageView *imageView;
    UIView *menuView;
    HSUStatusView *statusView;
    HSUStatusActionView *actionView;
    
    CGFloat menuStartTop;
    CGFloat startTouchY;
}

- (id)initWithData:(HSUTableCellData *)data imageURL:(NSURL *)imageURL
{
    self = [super initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    if (self) {
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
        menuView.backgroundColor = bwa(0, .8);
        
        UIView *border = [[UIView alloc] init];
        [menuView addSubview:border];
        border.size = ccs(self.width, 1);
        
        UIImageView *gripperView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_photo_detail_gripper"]];
        [menuView addSubview:gripperView];
        
        CGRect statusFrame = ccr(10, 10, self.width-20, [HSUStatusView heightForData:data]);
        statusView = [[HSUStatusView alloc] initWithFrame:statusFrame style:HSUStatusViewStyle_Gallery];
        [menuView addSubview:statusView];
        [statusView setupWithData:data];
        [statusView setNeedsLayout];
        
        UIView *sep = [[UIView alloc] init];
        [menuView addSubview:sep];
        sep.backgroundColor = bwa(255, .15);
        sep.size = ccs(self.width-10, 1);
        
        actionView = [[HSUStatusActionView alloc] initWithStatus:data.rawData style:HSUStatusActionViewStyle_Gallery];
        [menuView addSubview:actionView];
        actionView.size = ccs(self.width, 38);
        
        menuView.size = ccs(self.width, border.height+2+gripperView.height+5+statusView.height+sep.height+actionView.height);
        menuView.top = self.height - 17;
        
        border.leftTop = ccp(0, 0);
        gripperView.topCenter = ccp(menuView.width/2, border.bottom+2);
        statusView.topCenter = ccp(gripperView.bottomCenter.x, gripperView.bottomCenter.y+5);;
        sep.topCenter = statusView.bottomCenter;
        actionView.topCenter = sep.bottomCenter;
        
        progressBar.center = self.boundsCenter;
        imageView.frame = self.bounds;
        
        // gestures
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(_fireTapGesture:)];
        [self addGestureRecognizer:tapGesture];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] init];
        [longPressGesture addTarget:self action:@selector(_fireLongPressGesture:)];
        [self addGestureRecognizer:longPressGesture];
        
        UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] init];
        swipeGesture.direction = UISwipeGestureRecognizerDirectionDown|UISwipeGestureRecognizerDirectionUp;
        [swipeGesture addTarget:self action:@selector(_fireSwipeGesture:)];
        [self addGestureRecognizer:swipeGesture];
        
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
            [imageView setImage:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)hideWithAnimation:(BOOL)animation
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    if (animation) {
        [UIView animateWithDuration:.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    } else {
        [self removeFromSuperview];
    }
}

- (void)_fireTapGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self hideWithAnimation:YES];
    }
}

- (void)_fireLongPressGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *saveItem = [RIButtonItem itemWithLabel:@"Save image"];
        saveItem.action = ^{
            UIImageWriteToSavedPhotosAlbum(imageView.image, nil, nil, nil);
        };
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:saveItem, nil];
        [actionSheet showInView:self.window];
    }
}

- (void)_fireSwipeGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
    }
}

#pragma mark - touch events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    startTouchY = [touch locationInView:self].y;
    menuStartTop = menuView.top;
    
    if (startTouchY <= menuStartTop) {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = event.allTouches.anyObject;
    CGFloat y = [touch locationInView:self].y;
    
    if (startTouchY > menuStartTop) {
        menuView.top = menuStartTop + y - startTouchY;
    } else {
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startTouchY > menuStartTop) {
        [UIView animateWithDuration:0.2 animations:^{
            menuView.bottom = self.height;
        }];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (startTouchY > menuStartTop) {
        [UIView animateWithDuration:0.2 animations:^{
            menuView.bottom = self.height;
        }];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end
