//
//  HSUGalleryView.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUGalleryView.h"
#import "AFNetworking.h"

@implementation HSUGalleryView
{
    UIProgressView *progressBar;
    UIImageView *imageView;
}

- (id)initWithStatus:(NSDictionary *)status imageURL:(NSURL *)imageURL
{
    self = [super init];
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
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        // tap gesture
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(_fireTapGesture)];
        [self addGestureRecognizer:tapGesture];
        
        // load image
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        AFHTTPRequestOperation *downloader = [[AFImageRequestOperation alloc] initWithRequest:request];
        [downloader setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            [progressBar setProgress:bytesRead*1.0/totalBytesRead animated:YES];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    progressBar.center = self.boundsCenter;
    imageView.frame = self.bounds;
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

- (void)_fireTapGesture
{
    [self hideWithAnimation:YES];
}


@end
