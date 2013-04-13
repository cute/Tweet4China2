//
//  HSUComposeViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HSUComposeViewController.h"
#import "FHSTwitterEngine.h"
#import "FHSTwitterEngine+Additions.h"
#import "OARequestParameter.h"
#import "OAMutableURLRequest.h"
#import "HSUSuggestMentionCell.h"
#import <MapKit/MapKit.h>

#define kMaxWordLen 140
#define kSingleLineHeight 45
#define kSuggestionType_Mention 1
#define kSuggestionType_Tag 2

@interface HSULocationAnnotation : NSObject <MKAnnotation>
@end

@implementation HSULocationAnnotation
{
    CLLocationCoordinate2D coordinate;
}

- (CLLocationCoordinate2D)coordinate {
    return coordinate;
}

- (NSString *)title {
    return nil;
}

- (NSString *)subtitle {
    return nil;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end

@interface HSUComposeViewController () <UITextViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate>

@end

@implementation HSUComposeViewController
{
    UITextView *contentTV;
    UIView *toolbar;
    UIButton *photoBnt;
    UIButton *geoBnt;
    UIActivityIndicatorView *geoLoadingV;
    UIButton *mentionBnt;
    UIButton *tagBnt;
    UILabel *wordCountL;
    UIImageView *nippleIV;
    UIScrollView *extraPanelSV;
    UIButton *takePhotoBnt;
    UIButton *selectPhotoBnt;
    UIImageView *previewIV;
    UIButton *previewCloseBnt;
    MKMapView *mapView;
    UIImageView *mapOutlineIV;
    UILabel *locationL;
    UIButton *toggleLocationBnt;
    UITableView *suggestionsTV;
    UIImageView *contentShadowV;

    CGFloat keyboardHeight;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D location;
    NSArray *friends;
    NSArray *trends;
    NSUInteger suggestionType;
    NSMutableArray *filteredSuggestions;
    NSUInteger filterLocation;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameChanged:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

//    setup navigation bar
    self.title = @"New Tweet";
    self.navigationController.navigationBar.tintColor = bw(212);
    NSDictionary *attributes = @{UITextAttributeTextColor: bw(50),
            UITextAttributeTextShadowColor: kWhiteColor,
            UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 1)]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;

    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] init];
    cancelButtonItem.title = @"Cancel";
    cancelButtonItem.target = self;
    cancelButtonItem.action = @selector(cancelCompose);
    cancelButtonItem.tintColor = bw(220);
    self.navigationItem.leftBarButtonItem = cancelButtonItem;

    UIBarButtonItem *sendButtonItem = [[UIBarButtonItem alloc] init];
    sendButtonItem.title = @"Tweet";
    sendButtonItem.target = self;
    sendButtonItem.action = @selector(sendTweet);
    sendButtonItem.tintColor = bw(220);
    sendButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = sendButtonItem;

    NSDictionary *disabledAttributes = @{UITextAttributeTextColor: bw(129),
            UITextAttributeTextShadowColor: kWhiteColor,
            UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:ccs(0, 1)]};
    [cancelButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [cancelButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [cancelButtonItem setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];

    attributes = @{UITextAttributeTextColor: kWhiteColor,
            UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:ccs(0, -1)]};
    disabledAttributes = @{UITextAttributeTextColor: bw(129),
            UITextAttributeTextShadowColor: kWhiteColor,
            UITextAttributeTextShadowOffset: [NSValue valueWithCGSize:ccs(0, 1)]};
    [sendButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [sendButtonItem setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
    [sendButtonItem setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];

//    setup view
    self.view.backgroundColor = kWhiteColor;
    contentTV = [[UITextView alloc] init];
    [self.view addSubview:contentTV];
    contentTV.font = [UIFont systemFontOfSize:16];
    contentTV.delegate = self;
    contentTV.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"draft"];

    toolbar =[UIImageView viewStrechedNamed:@"button-bar-background"];
    [self.view addSubview:toolbar];
    toolbar.userInteractionEnabled = YES;

    photoBnt = [[UIButton alloc] init];
    [toolbar addSubview:photoBnt];
    [photoBnt addTarget:self action:@selector(photoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [photoBnt setImage:[UIImage imageNamed:@"button-bar-camera"] forState:UIControlStateNormal];
    photoBnt.showsTouchWhenHighlighted = YES;
    [photoBnt sizeToFit];
    photoBnt.center = ccp(25, 20);
    photoBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);

    geoBnt = [[UIButton alloc] init];
    [toolbar addSubview:geoBnt];
    [geoBnt addTarget:self action:@selector(geoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [geoBnt setImage:[UIImage imageNamed:@"compose-geo"] forState:UIControlStateNormal];
    geoBnt.showsTouchWhenHighlighted = YES;
    [geoBnt sizeToFit];
    geoBnt.center = ccp(85, 20);
    geoBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);

    geoLoadingV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [toolbar addSubview:geoLoadingV];
    geoLoadingV.center = geoBnt.center;
    geoLoadingV.hidesWhenStopped = YES;

    mentionBnt = [[UIButton alloc] init];
    [toolbar addSubview:mentionBnt];
    [mentionBnt setTapTarget:self action:@selector(mentionButtonTouched)];
    [mentionBnt setImage:[UIImage imageNamed:@"button-bar-at"] forState:UIControlStateNormal];
    mentionBnt.showsTouchWhenHighlighted = YES;
    [mentionBnt sizeToFit];
    mentionBnt.center = ccp(145, 20);
    mentionBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);

    tagBnt = [[UIButton alloc] init];
    [toolbar addSubview:tagBnt];
    [tagBnt setTapTarget:self action:@selector(tagButtonTouched)];
    [tagBnt setImage:[UIImage imageNamed:@"button-bar-hashtag"] forState:UIControlStateNormal];
    tagBnt.showsTouchWhenHighlighted = YES;
    [tagBnt sizeToFit];
    tagBnt.center = ccp(205, 20);
    tagBnt.hitTestEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);

    wordCountL = [[UILabel alloc] init];
    [toolbar addSubview:wordCountL];
    wordCountL.font = [UIFont systemFontOfSize:14];
    wordCountL.textColor = bw(140);
    wordCountL.shadowColor = kWhiteColor;
    wordCountL.shadowOffset = ccs(0, 1);
    wordCountL.backgroundColor = kClearColor;
    wordCountL.text = S(@"%d", kMaxWordLen);
    [wordCountL sizeToFit];
    wordCountL.center = ccp(294, 20);

    nippleIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compose-nipple"]];
    [toolbar addSubview:nippleIV];
    nippleIV.center = photoBnt.center;
    nippleIV.bottom = toolbar.height + 1;

    extraPanelSV = [[UIScrollView alloc] init];
    [self.view addSubview:extraPanelSV];
    extraPanelSV.left = 0;
    extraPanelSV.width = self.view.width;
    extraPanelSV.pagingEnabled = YES;
    extraPanelSV.delegate = self;
    extraPanelSV.showsHorizontalScrollIndicator = NO;
    extraPanelSV.showsVerticalScrollIndicator = NO;
    extraPanelSV.backgroundColor = bw(232);
    extraPanelSV.alwaysBounceVertical = NO;

    takePhotoBnt = [[UIButton alloc] init];
    [extraPanelSV addSubview:takePhotoBnt];
    [takePhotoBnt setTapTarget:self action:@selector(takePhotoButtonTouched)];
    [takePhotoBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button"] stretchableImageFromCenter] forState:UIControlStateNormal];
    [takePhotoBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button-pressed"] stretchableImageFromCenter] forState:UIControlStateHighlighted];
    [takePhotoBnt setTitle:@"Take photo or video..." forState:UIControlStateNormal];
    [takePhotoBnt setTitleColor:rgb(52, 80, 112) forState:UIControlStateNormal];
    takePhotoBnt.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [takePhotoBnt sizeToFit];
    takePhotoBnt.width = extraPanelSV.width - 20;
    takePhotoBnt.topCenter = ccp(extraPanelSV.center.x, 11);

    selectPhotoBnt = [[UIButton alloc] init];
    [extraPanelSV addSubview:selectPhotoBnt];
    [selectPhotoBnt setTapTarget:self action:@selector(selectPhotoButtonTouched)];
    [selectPhotoBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button"] stretchableImageFromCenter] forState:UIControlStateNormal];
    [selectPhotoBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button-pressed"] stretchableImageFromCenter] forState:UIControlStateHighlighted];
    [selectPhotoBnt setTitle:@"Choose from library..." forState:UIControlStateNormal];
    [selectPhotoBnt setTitleColor:rgb(52, 80, 112) forState:UIControlStateNormal];
    selectPhotoBnt.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    selectPhotoBnt.frame = takePhotoBnt.frame;
    selectPhotoBnt.top = selectPhotoBnt.bottom + 10;

    previewIV = [[UIImageView alloc] init];
    [extraPanelSV addSubview:previewIV];
    previewIV.hidden = YES;
    previewIV.layer.cornerRadius = 3;

    previewCloseBnt = [[UIButton alloc] init];
    [extraPanelSV addSubview:previewCloseBnt];
    [previewCloseBnt setTapTarget:self action:@selector(previewCloseButtonTouched)];
    previewCloseBnt.hidden = YES;
    [previewCloseBnt setImage:[UIImage imageNamed:@"UIBlackCloseButton"] forState:UIControlStateNormal];
    [previewCloseBnt setImage:[UIImage imageNamed:@"UIBlackCloseButtonPressed"] forState:UIControlStateHighlighted];
    [previewCloseBnt sizeToFit];

    mapView = [[MKMapView alloc] init];
    [extraPanelSV addSubview:mapView];
    mapView.zoomEnabled = NO;
    mapView.scrollEnabled = NO;
    mapView.frame = ccr(extraPanelSV.width + 10, 10, extraPanelSV.width - 20, 125);
    mapOutlineIV = [UIImageView viewStrechedNamed:@"compose-map-outline"];
    [extraPanelSV addSubview:mapOutlineIV];
    mapOutlineIV.frame = mapView.frame;

    locationL = [[UILabel alloc] init];
    [extraPanelSV addSubview:locationL];
    locationL.backgroundColor = kClearColor;
    locationL.font = [UIFont systemFontOfSize:14];
    locationL.textColor = bw(140);
    locationL.shadowColor = kWhiteColor;
    locationL.shadowOffset = ccs(0, 1);
    locationL.textAlignment = NSTextAlignmentCenter;
    locationL.numberOfLines = 1;
    locationL.frame = ccr(mapView.left, mapView.bottom, mapView.width, 30);

    toggleLocationBnt = [[UIButton alloc] init];
    [extraPanelSV addSubview:toggleLocationBnt];
    [toggleLocationBnt setTapTarget:self action:@selector(toggleLocationButtonTouched)];
    [toggleLocationBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button"] stretchableImageFromCenter] forState:UIControlStateNormal];
    [toggleLocationBnt setBackgroundImage:[[UIImage imageNamed:@"compose-map-toggle-button-pressed"] stretchableImageFromCenter] forState:UIControlStateHighlighted];
    [toggleLocationBnt setTitle:@"Turn off location" forState:UIControlStateNormal];
    [toggleLocationBnt setTitleColor:rgb(52, 80, 112) forState:UIControlStateNormal];
    toggleLocationBnt.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    toggleLocationBnt.frame = takePhotoBnt.frame;
    toggleLocationBnt.left += extraPanelSV.width;

    suggestionsTV = [[UITableView alloc] init];
    [self.view addSubview:suggestionsTV];
    suggestionsTV.hidden = YES;
    suggestionsTV.delegate = self;
    suggestionsTV.dataSource = self;
    suggestionsTV.top = 45;
    suggestionsTV.width = self.view.width;
    suggestionsTV.rowHeight = 37;
    suggestionsTV.backgroundColor = bw(232);
    suggestionsTV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    suggestionsTV.separatorColor = bw(217);
    [suggestionsTV registerClass:[HSUSuggestMentionCell class] forCellReuseIdentifier:[[HSUSuggestMentionCell class] description]];

    contentShadowV = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"searches-top-shadow.png"] stretchableImageFromCenter]];
    [self.view addSubview:contentShadowV];
    contentShadowV.hidden = YES;
    contentShadowV.top = suggestionsTV.top;
    contentShadowV.width = suggestionsTV.width;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!self.presentingViewController)
        [contentTV becomeFirstResponder];
    [self textViewDidChange:contentTV];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.pausesLocationUpdatesAutomatically = YES;
    [locationManager startUpdatingLocation];
    geoBnt.hidden = YES;
    [geoLoadingV startAnimating];

    friends = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends"];
    dispatch_async(GCDBackgroundThread, ^{
        id result = [[FHSTwitterEngine engine] getFriendsMoreThanID];
        if ([result isKindOfClass:[NSArray class]]) {
            friends = result;
            [[NSUserDefaults standardUserDefaults] setObject:friends forKey:@"friends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self filterSuggestions];
            });
        }
    });

    dispatch_async(GCDBackgroundThread, ^{
        id result = [[FHSTwitterEngine engine] getTrends];
        if ([result isKindOfClass:[NSArray class]] && [result count]) {
            trends = result[0][@"trends"];
            [[NSUserDefaults standardUserDefaults] setObject:trends forKey:@"trends"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self filterSuggestions];
            });
        }
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [locationManager stopUpdatingLocation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat toolbar_height = 40;
    contentTV.frame = ccr(0, 0, self.view.width, self.view.height- MAX(keyboardHeight, 216)-toolbar_height);
    toolbar.frame = ccr(0, contentTV.bottom, self.view.width, toolbar_height);
    extraPanelSV.top = toolbar.bottom;
    extraPanelSV.height = self.view.height - extraPanelSV.top;
    extraPanelSV.contentSize = ccs(extraPanelSV.width*2, extraPanelSV.height);
    previewIV.frame = ccr(30, 30, extraPanelSV.width-60, extraPanelSV.height-60);
    previewCloseBnt.center = previewIV.rightTop;
    toggleLocationBnt.bottom = extraPanelSV.height - 10;

    if (suggestionType) {
        suggestionsTV.hidden = NO;
        contentShadowV.hidden = NO;
        contentTV.height = kSingleLineHeight;
        suggestionsTV.height = self.view.height - suggestionsTV.top - keyboardHeight;
    } else {
        suggestionsTV.hidden = YES;
        contentShadowV.hidden = YES;
    }
}

- (void)keyboardFrameChanged:(NSNotification *)notification
{
    NSValue* keyboardFrame = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardHeight = keyboardFrame.CGRectValue.size.height;
    [self.view setNeedsLayout];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    nippleIV.hidden = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    nippleIV.hidden = YES;
}

- (void)cancelCompose
{
    if (contentTV.text.length) {
        RIButtonItem *cancelBnt = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *giveUpBnt = [RIButtonItem itemWithLabel:@"Don't save"];
        giveUpBnt.action = ^{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        RIButtonItem *saveBnt = [RIButtonItem itemWithLabel:@"Save draft"];
        saveBnt.action = ^{
            [[NSUserDefaults standardUserDefaults] setObject:contentTV.text forKey:@"draft"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelBnt destructiveButtonItem:nil otherButtonItems:giveUpBnt, saveBnt, nil];
        actionSheet.destructiveButtonIndex = 0;
        [actionSheet showInView:self.view.window];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)sendTweet
{
    if (contentTV.text == nil) return;
    dispatch_async(GCDBackgroundThread, ^{
        NSURL *baseURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];

        NSMutableArray *params = [NSMutableArray array];

        OARequestParameter *statusP = [OARequestParameter requestParameterWithName:@"status" value:contentTV.text];
        [params addObject:statusP];

        if (previewIV.image) {
            OARequestParameter *mediaP = [OARequestParameter requestParameterWithName:@"media_data[]" value:[UIImageJPEGRepresentation(previewIV.image, 0.92) base64EncodingWithLineLength:0]];
            [params addObject:mediaP];
        }
        if (location.latitude && location.longitude) {
            OARequestParameter *latP = [OARequestParameter requestParameterWithName:@"lat" value:S(@"%g", location.latitude)];
            OARequestParameter *longP = [OARequestParameter requestParameterWithName:@"long" value:S(@"%g", location.longitude)];
            [params addObject:latP];
            [params addObject:longP];
        }

        OAMutableURLRequest *request = [[FHSTwitterEngine engine] requestWithBaseURL:baseURL];
        NSError *err = [[FHSTwitterEngine engine] sendPOSTRequest:request withParameters:params];
        if (err == nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"draft"];
        }
        [FHSTwitterEngine dealWithError:err errTitle:@"Send status failed"];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newText = [contentTV.text stringByReplacingCharactersInRange:range withString:text];
    return ([FHSTwitterEngine twitterTextLength:newText] <= 140);
}

- (void)textViewDidChange:(UITextView *)textView {
    NSUInteger wordLen = [FHSTwitterEngine twitterTextLength:contentTV.text];
    if (wordLen > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.tintColor = rgb(52, 172, 232);
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.tintColor = bw(220);
    }
    wordCountL.text = S(@"%d", kMaxWordLen-wordLen);
    
    [self filterSuggestions];
}

- (void)filterSuggestions {
    if (suggestionType) {
        NSInteger len = contentTV.selectedRange.location-filterLocation;
        if (len >= 0) {
            NSString *filterText = [contentTV.text substringWithRange:NSMakeRange(filterLocation, len)];
            NSString *trimmedText = [filterText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![trimmedText isEqualToString:filterText]) {
                suggestionType = 0;
                filteredSuggestions = nil;
                [self.view setNeedsLayout];
            }
            if (suggestionType == kSuggestionType_Mention && friends) {
                if (filterText && filterText.length) {
                    if (filteredSuggestions == nil) {
                        filteredSuggestions = [NSMutableArray array];
                    } else {
                        [filteredSuggestions removeAllObjects];
                    }
                    for (NSDictionary *friend in friends) {
                        NSString *screenName = friend[@"screen_name"];
                        if ([screenName rangeOfString:filterText].location != NSNotFound) {
                            [filteredSuggestions addObject:friend];
                        }
                    }
                } else {
                    filteredSuggestions = [friends mutableCopy];
                }
            } else if (suggestionType == kSuggestionType_Tag && trends) {
                if (filterText && filterText.length) {
                    if (filteredSuggestions == nil) {
                        filteredSuggestions = [NSMutableArray array];
                    } else {
                        [filteredSuggestions removeAllObjects];
                    }
                    for (NSDictionary *trend in trends) {
                        NSString *tag = [[trend[@"name"] substringFromIndex:1] lowercaseString];
                        if (tag && [tag rangeOfString:filterText].location != NSNotFound) {
                            [filteredSuggestions addObject:trend];
                        }
                    }
                } else {
                    filteredSuggestions = [trends mutableCopy];
                }
            }
            [suggestionsTV reloadData];
        } else {
            suggestionType = 0;
            filteredSuggestions = nil;
            [self.view setNeedsLayout];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat left = photoBnt.center.x - nippleIV.width / 2;
    CGFloat right = geoBnt.center.x - nippleIV.width / 2;
    nippleIV.left = left + (right - left) * scrollView.contentOffset.x / scrollView.width;
}

#pragma mark - Actions
- (void)photoButtonTouched {
    if (contentTV.isFirstResponder || extraPanelSV.contentOffset.x > 0) {
        [contentTV resignFirstResponder];
        [extraPanelSV setContentOffset:ccp(0, 0) animated:YES];
    } else {
        [contentTV becomeFirstResponder];
    }
}

- (void)takePhotoButtonTouched {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)selectPhotoButtonTouched {
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    [self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = [image scaleToWidth:640];

    CGFloat height = previewIV.height / previewIV.width * image.size.width;
    CGFloat top = image.size.height/2 - height/2;
    CGImageRef imageRef = CGImageCreateWithImageInRect(image.CGImage, ccr(0, top, image.size.width, height));
    previewIV.image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    takePhotoBnt.hidden = YES;
    selectPhotoBnt.hidden = YES;
    previewIV.hidden = NO;
    previewCloseBnt.hidden = NO;
    [photoBnt setImage:[UIImage imageNamed:@"button-bar-camera-glow"] forState:UIControlStateNormal];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewCloseButtonTouched {
    previewCloseBnt.hidden = YES;
    [UIView animateWithDuration:0.2 animations:^{
        previewIV.transform = CGAffineTransformMakeScale(0, 0);
        previewIV.alpha = 0;
        previewIV.center = extraPanelSV.boundsCenter;
    } completion:^(BOOL finished) {
        previewIV.image = nil;
        previewIV.hidden = YES;
        takePhotoBnt.hidden = NO;
        selectPhotoBnt.hidden = NO;
        previewIV.transform = CGAffineTransformMakeTranslation(1, 1);
        previewIV.alpha = 1;
        previewIV.center = extraPanelSV.boundsCenter;
    }];

    [photoBnt setImage:[UIImage imageNamed:@"button-bar-camera"] forState:UIControlStateNormal];
}

- (void)geoButtonTouched {
    if (contentTV.isFirstResponder ||  extraPanelSV.contentOffset.x == 0) {
        if (contentTV.isFirstResponder) {
            [locationManager startUpdatingLocation];
            geoBnt.hidden = YES;
            [geoLoadingV startAnimating];
            [toggleLocationBnt setTitle:@"Turn off location" forState:UIControlStateNormal];
            mapOutlineIV.backgroundColor = kClearColor;
        }

        [extraPanelSV setContentOffset:ccp(extraPanelSV.width, 0) animated:YES];
        [contentTV resignFirstResponder];
    } else {
        [contentTV becomeFirstResponder];
    }
}

- (void)toggleLocationButtonTouched {
    if (toggleLocationBnt.tag) {
        [contentTV becomeFirstResponder];
        [geoBnt setImage:[UIImage imageNamed:@"compose-geo"] forState:UIControlStateNormal];
        geoBnt.hidden = NO;
        [locationManager stopUpdatingLocation];
        [toggleLocationBnt setTitle:@"Turn on location" forState:UIControlStateNormal];
        [mapView removeAnnotations:mapView.annotations];
        mapOutlineIV.backgroundColor = rgba(1, 1, 1, 0.2);
        toggleLocationBnt.tag = 0;
        [geoLoadingV stopAnimating];
    } else {
        [locationManager startUpdatingLocation];
        geoBnt.hidden = YES;
        [geoLoadingV startAnimating];
        [toggleLocationBnt setTitle:@"Turn off location" forState:UIControlStateNormal];
        mapOutlineIV.backgroundColor = kClearColor;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:manager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            locationL.text = placemark.name;
            break;
        }
    }];


    [geoBnt setImage:[UIImage imageNamed:@"compose-geo-highlighted"] forState:UIControlStateNormal];
    geoBnt.hidden = NO;
    [geoLoadingV stopAnimating];
    toggleLocationBnt.tag = 1;

    location = manager.location.coordinate;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(location, 200, 200);
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];
    [mapView setRegion:adjustedRegion animated:YES];
    [mapView setCenterCoordinate:location animated:YES];

    HSULocationAnnotation *annotation = [[HSULocationAnnotation alloc] init];
    annotation.coordinate = location;
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotation:annotation];
}

- (void)mentionButtonTouched {
    NSRange range = contentTV.selectedRange;
    if (range.location == NSNotFound)
        range = NSMakeRange(0, 0);
    contentTV.text = [contentTV.text stringByReplacingCharactersInRange:range withString:@"@"];
    [contentTV becomeFirstResponder];
    contentTV.selectedRange = NSMakeRange(range.location+1, 0);
    suggestionType = kSuggestionType_Mention;
    filterLocation = contentTV.selectedRange.location;
    filteredSuggestions = [friends mutableCopy];
    [suggestionsTV reloadData];
    [self.view setNeedsLayout];
}

- (void)tagButtonTouched {
    NSRange range = contentTV.selectedRange;
    if (range.location == NSNotFound)
        range = NSMakeRange(0, 0);
    contentTV.text = [contentTV.text stringByReplacingCharactersInRange:range withString:@"#"];
    [contentTV becomeFirstResponder];
    contentTV.selectedRange = NSMakeRange(range.location+1, 0);
    suggestionType = kSuggestionType_Tag;
    filterLocation = contentTV.selectedRange.location;
    filteredSuggestions = [trends mutableCopy];
    [suggestionsTV reloadData];
    [self.view setNeedsLayout];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(filteredSuggestions.count, 30);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (suggestionType == kSuggestionType_Mention) {
        HSUSuggestMentionCell *cell = [tableView dequeueReusableCellWithIdentifier:[[HSUSuggestMentionCell class] description] forIndexPath:indexPath];
        NSDictionary *friend = filteredSuggestions[indexPath.row];
        NSString *avatar = friend[@"profile_image_url_https"];
        NSString *name = friend[@"name"];
        NSString *screenName = friend[@"screen_name"];
        [cell setAvatar:avatar name:name screenName:screenName];
        return cell;
    } else if (suggestionType == kSuggestionType_Tag) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HSUSuggestTagCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HSUSuggestTagCell"];
        }
        NSDictionary *trend = filteredSuggestions[indexPath.row];
        NSString *tag = [trend[@"name"] substringFromIndex:1];
        cell.textLabel.text = tag;
        return cell;
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *replacement = nil;
    if (suggestionType == kSuggestionType_Mention) {
        NSDictionary *friend = filteredSuggestions[indexPath.row];
        replacement = S(@"%@ ", friend[@"screen_name"]);
    } else if (suggestionType == kSuggestionType_Tag) {
        NSDictionary *trend = filteredSuggestions[indexPath.row];
        replacement = S(@"%@ ", [trend[@"name"] substringFromIndex:1]);
    }
    NSRange range = NSMakeRange(filterLocation, contentTV.selectedRange.location - filterLocation);
    if ([self textView:contentTV shouldChangeTextInRange:range replacementText:replacement]) {
        contentTV.text = [contentTV.text stringByReplacingCharactersInRange:range withString:replacement];
    }
    suggestionType = 0;
    filteredSuggestions = nil;
    [self.view setNeedsLayout];
}

@end
