//
//  HSUMessageViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUMessagesViewController.h"
#import "HSUMessagesDataSource.h"

@interface HSUMessagesViewController () <UITextViewDelegate>

@property (nonatomic, weak) UIView *toolbar;
@property (nonatomic, weak) UIImageView *textViewBackground;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *wordCountLabel;
@property (nonatomic, assign) float keyboardHeight;
@property (nonatomic, assign) BOOL layoutForTextChanged;

@end

@implementation HSUMessagesViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.hideBackButton = YES;
        self.hideRightButtons = YES;
        self.useRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = kWhiteColor;
    
    // setup navigation bar
    self.navigationController.navigationBar.tintColor = bw(212);
    NSDictionary *attributes = @{UITextAttributeTextColor: bw(30),
                                 UITextAttributeTextShadowColor: kWhiteColor,
                                 UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 1)]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    // setup navgation bar buttons
    UIButton *backButton = [[UIButton alloc] init];
    [backButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_back"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    backButton.width *= 1.4;
    backButton.showsTouchWhenHighlighted = YES;
    [backButton setTapTarget:self action:@selector(_backButtonTouched)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *actionsButton = [[UIButton alloc] init];
    [actionsButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_actions"] forState:UIControlStateNormal];
    [actionsButton sizeToFit];
    actionsButton.width *= 1.4;
    actionsButton.showsTouchWhenHighlighted = YES;
    [actionsButton setTapTarget:self action:@selector(_actionsButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:actionsButton];
    
    UIView *toolbar = [[UIView alloc] init];
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    toolbar.backgroundColor = [UIColor greenColor];
    
    UIImageView *textViewBackground = [[UIImageView alloc] init];
    [self.view addSubview:textViewBackground];
    self.textViewBackground = textViewBackground;
    textViewBackground.image = [[UIImage imageNamed:@"direct-message-text-bubble"] stretchableImageFromCenter];
    
    UITextView *textView = [[UITextView alloc] init];
    [self.view addSubview:textView];
    self.textView = textView;
    textView.delegate = self;
    textView.backgroundColor = kClearColor;
    textView.font = [UIFont systemFontOfSize:15];
    textView.textColor = kBlackColor;
    
    UILabel *wordCountLabel = [[UILabel alloc] init];
    [self.view addSubview:wordCountLabel];
    self.wordCountLabel = wordCountLabel;
    wordCountLabel.textColor = kGrayColor;
    wordCountLabel.font = [UIFont boldSystemFontOfSize:14];
    wordCountLabel.shadowColor = kWhiteColor;
    wordCountLabel.shadowOffset = ccs(0, 1);
    wordCountLabel.backgroundColor = kClearColor;
    wordCountLabel.text = @"140";
    [wordCountLabel sizeToFit];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.textView.width == 0) {
        self.textView.size = ccs(275, 0);
    }
    CGSize textViewSize = self.textView.contentSize;
    if (textViewSize.height > 100) {
        textViewSize = ccs(textViewSize.width, 100);
    }
    CGSize textViewBackgroundSize = ccs(textViewSize.width, textViewSize.height-8);
    CGSize toolbarSize = ccs(self.width, textViewBackgroundSize.height+9+7);
    void (^animatedBlock)() = ^{
        self.tableView.height = self.height - self.keyboardHeight - toolbarSize.height;
        self.toolbar.size = toolbarSize;
        self.toolbar.bottom = self.height - self.keyboardHeight;
        self.textViewBackground.leftTop = ccp(5, self.toolbar.top + 9);
        self.textViewBackground.size = textViewBackgroundSize;
        self.textView.size = textViewSize;
        self.textView.leftTop = ccp(12, self.tableView.bottom+5);
        self.wordCountLabel.rightCenter = ccp(self.width-10, self.toolbar.rightCenter.y);
    };
    if (self.viewDidAppearCount == 0 || self.layoutForTextChanged) {
        self.layoutForTextChanged = NO;
        animatedBlock();
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            animatedBlock();
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.wordCountLabel.text = S(@"%u", 140-self.textView.text.length);
    [self.wordCountLabel sizeToFit];
    self.layoutForTextChanged = YES;
    [self.view setNeedsLayout];
}

@end
