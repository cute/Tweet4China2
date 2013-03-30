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

@interface HSUComposeViewController () <UITextViewDelegate>

@end

@implementation HSUComposeViewController
{
    UITextView *contentTV;
    UIImageView *contentShadowV;
    UIView *toolbar;
    UIButton *photoBnt;
    UIButton *locationBnt;
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
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

//    setup navigation bar
    self.navigationController.navigationBar.tintColor = bw(212);

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

    NSDictionary *attributes = @{UITextAttributeTextColor: bw(43),
            UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 0)]};
    NSDictionary *disabledAttributes = @{UITextAttributeTextColor: bw(129),
            UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 0)]};
    [cancelButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [cancelButtonItem setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];
    [sendButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [sendButtonItem setTitleTextAttributes:disabledAttributes forState:UIControlStateDisabled];

//    setup view
    self.view.backgroundColor = kWhiteColor;
    contentTV = [[UITextView alloc] init];
    [self.view addSubview:contentTV];
    contentTV.contentInset = UIEdgeInsetsMake(5, 5, 5, 5);
    contentTV.font = [UIFont systemFontOfSize:16];
    contentTV.textColor = bw(43);
    contentTV.delegate = self;

//    contentShadowV = [UIImageView viewNamed:@""];
    toolbar =[UIImageView viewStrechedNamed:@"button-bar-background"];
    [self.view addSubview:toolbar];
    photoBnt = [[UIButton alloc] init];
    locationBnt = [[UIButton alloc] init];
    memtionBnt = [[UIButton alloc] init];
    tagBnt = [[UIButton alloc] init];
    wordCountL = [[UILabel alloc] init];
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
    NSValue* keyboardFrameBegin = [notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardHeight = keyboardFrameBegin.CGRectValue.size.height;

    [self.view setNeedsLayout];
}

- (void)cancelCompose
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendTweet
{
    FHSTwitterEngine *twitterEngine = [FHSTwitterEngine engine];
    NSError *error = [twitterEngine postTweet:contentTV.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidChange:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem.enabled = contentTV.text.length > 0;
}

@end
