//
//  HSUComposeViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUComposeViewController.h"
#import "FHSTwitterEngine.h"
#import "FHSTwitterEngine+Addition.h"

#define kMaxWordLen 140

@interface HSUComposeViewController () <UITextViewDelegate>

@end

@implementation HSUComposeViewController
{
    UITextView *contentTV;
    UIImageView *contentShadowV;
    UIView *toolbar;
    UIButton *photoBnt;
    UIButton *geoBnt;
    UIButton *memtionBnt;
    UIButton *tagBnt;
    UILabel *wordCountL;
    UIButton *takePhotoBnt;
    UIButton *selectPhotoBnt;
    UIView *locationView;
    UILabel *locationL;
    UIButton *toggleLocationBnt;
    UITableView *contactsTV;
    UITableView *tagsTV;
    
    CGFloat keyboardHeight;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppearance:)
                                                 name:UIKeyboardWillChangeFrameNotification
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

//    contentShadowV = [UIImageView viewNamed:@""];
    toolbar =[UIImageView viewStrechedNamed:@"button-bar-background"];
    [self.view addSubview:toolbar];

    photoBnt = [[UIButton alloc] init];
    [toolbar addSubview:photoBnt];
    [photoBnt setImage:[UIImage imageNamed:@"button-bar-camera"] forState:UIControlStateNormal];
    [photoBnt setImage:[UIImage imageNamed:@"button-bar-camera-glow"] forState:UIControlStateHighlighted];
    [photoBnt sizeToFit];
    photoBnt.center = ccp(25, 20);

    geoBnt = [[UIButton alloc] init];
    [toolbar addSubview:geoBnt];
    [geoBnt setImage:[UIImage imageNamed:@"compose-geo"] forState:UIControlStateNormal];
    [geoBnt setImage:[UIImage imageNamed:@"compose-geo-highlighted"] forState:UIControlStateHighlighted];
    [geoBnt sizeToFit];
    geoBnt.center = ccp(85, 20);

    memtionBnt = [[UIButton alloc] init];
    [toolbar addSubview:memtionBnt];
    [memtionBnt setImage:[UIImage imageNamed:@"button-bar-at"] forState:UIControlStateNormal];
    [memtionBnt sizeToFit];
    memtionBnt.center = ccp(145, 20);

    tagBnt = [[UIButton alloc] init];
    [toolbar addSubview:tagBnt];
    [tagBnt setImage:[UIImage imageNamed:@"button-bar-hashtag"] forState:UIControlStateNormal];
    [tagBnt sizeToFit];
    tagBnt.center = ccp(205, 20);

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

    takePhotoBnt = [[UIButton alloc] init];
    selectPhotoBnt = [[UIButton alloc] init];
    locationView = [[UIView alloc] init];
    locationL = [[UILabel alloc] init];
    toggleLocationBnt = [[UIButton alloc] init];
    contactsTV = [[UITableView alloc] init];
    tagsTV = [[UITableView alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [contentTV becomeFirstResponder];
    [self textViewDidChange:contentTV];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat toolbar_height = 40;
    contentTV.frame = ccr(0, 0, self.view.width, self.view.height-keyboardHeight-toolbar_height);
    toolbar.frame = ccr(0, contentTV.bottom, self.view.width, toolbar_height);
}

- (void)keyboardAppearance:(NSNotification *)notification
{
    NSValue* keyboardFrame = [notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    keyboardHeight = keyboardFrame.CGRectValue.size.height;
    [self.view setNeedsLayout];
}

- (void)cancelCompose
{
    if (contentTV.text.length) {
        RIButtonItem *cancelBnt = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *giveUpBnt = [RIButtonItem itemWithLabel:@"Don't save"];
        giveUpBnt.action = ^{
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"draft"];
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
        NSError *err = [[FHSTwitterEngine engine] postTweet:contentTV.text];
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
}

@end
