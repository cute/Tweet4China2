//
//  HSUMiniBrowser.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/29/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUMiniBrowser.h"
#import "HSUStatusView.h"
#import "HSUStatusActionView.h"
#import "HSUStatusViewController.h"

@interface HSUMiniBrowser () <UIWebViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) HSUTableCellData *cellData;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) HSUStatusActionView *actionView;

@end

@implementation HSUMiniBrowser

- (id)initWithURL:(NSURL *)url cellData:(HSUTableCellData *)cellData
{
    self = [super init];
    if (self) {
        self.url = url;
        self.cellData = cellData;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Loading...";
    self.view.backgroundColor = bw(0xd0);
    
    NSDictionary *attributes = @{UITextAttributeTextColor: bw(50),
                                 UITextAttributeTextShadowColor: kWhiteColor,
                                 UITextAttributeTextShadowOffset: [NSValue valueWithCGPoint:ccp(0, 1)]};
    self.navigationController.navigationBar.titleTextAttributes = attributes;
    
    // subviews
    UIWebView *webview = [[UIWebView alloc] init];
    [self.view addSubview:webview];
    self.webview = webview;
    webview.delegate = self;
    webview.scrollView.delegate = self;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url];
    [webview loadRequest:request];
    UIColor *webviewBGC = [UIColor clearColor];
    webview.backgroundColor = webviewBGC;
    UIView *diandian = [[UIView alloc] initWithFrame:self.view.bounds];
    diandian.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_swipe_tile"]];
    [self.view insertSubview:diandian belowSubview:webview];
    diandian.alpha = 0.2;
    
    // menu view
    UIView *menuView = [[UIView alloc] init];
    [self.view addSubview:menuView];
    self.menuView = menuView;
    menuView.backgroundColor = bw(240);
    
    UIView *border = [[UIView alloc] init];
    [menuView addSubview:border];
    border.backgroundColor = bw(197);
    
    UIImageView *gripperView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn_webview_detail_gripper"]];
    [menuView addSubview:gripperView];
    
    CGFloat statusHeight = [HSUStatusView heightForData:self.cellData
                                        constraintWidth:self.width-20];
    HSUStatusView *statusView = [[HSUStatusView alloc] initWithFrame:ccr(0, 0, self.width-20, statusHeight)
                                                style:HSUStatusViewStyle_Light];
    [menuView addSubview:statusView];
    statusView.backgroundColor = kClearColor;
    [statusView setupWithData:self.cellData];
    
    UIView *sep = [[UIView alloc] init];
    [menuView addSubview:sep];
    sep.backgroundColor = bw(217);
    
    HSUStatusActionView *actionView = [[HSUStatusActionView alloc] initWithStatus:self.cellData.rawData style:HSUStatusActionViewStyle_Default];
    [menuView addSubview:actionView];
    self.actionView = actionView;
    
    [actionView.replayB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionView.retweetB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionView.favoriteB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionView.moreB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
    [actionView.deleteB addTarget:self action:@selector(_fireAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // set frames
    sep.size = ccs(self.width-10, 1);
    actionView.size = ccs(self.width, 38);
    menuView.size = ccs(self.width, 0);
    
    border.frame = ccr(0, 1, menuView.width, 1);
    gripperView.topCenter = ccp(menuView.width/2, border.bottom+2);
    statusView.topCenter = ccp(gripperView.bottomCenter.x, gripperView.bottomCenter.y+5);;
    sep.topCenter = statusView.bottomCenter;
    actionView.topCenter = sep.bottomCenter;
    menuView.height = actionView.bottom + 5;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_close"] forState:UIControlStateNormal];
    [closeButton sizeToFit];
    closeButton.width *= 1.2;
    closeButton.showsTouchWhenHighlighted = YES;
    [closeButton setTapTarget:self action:@selector(_closeButtonTouched)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    
    UIButton *actionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [actionsButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_actions"] forState:UIControlStateNormal];
    [actionsButton sizeToFit];
    actionsButton.width *= 1.6;
    actionsButton.showsTouchWhenHighlighted = YES;
    [actionsButton setTapTarget:self action:@selector(_actionsButtonTouched)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:actionsButton];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [tapGesture addTarget:self action:@selector(_fireTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] init];
    swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
    [swipeDownGesture addTarget:self action:@selector(_fireSwipeDownGesture:)];
    [self.view addGestureRecognizer:swipeDownGesture];
    
    UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] init];
    swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [swipeUpGesture addTarget:self action:@selector(_fireSwipeUpGesture:)];
    [self.view addGestureRecognizer:swipeUpGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.webview.frame = ccr(0, 0, self.width, self.height-17);
    self.menuView.bottom = self.height;
}

#pragma mark - webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.menuView.top = self.height - 17;
    }];
}

#pragma mark - actions
- (void)_fireAction:(id)sender
{
    UIEvent *event = nil;
    if (sender == self.actionView.replayB) {
        event = self.cellData.renderData[@"reply"];
    } else if (sender == self.actionView.retweetB) {
        event = self.cellData.renderData[@"retweet"];
    } else if (sender == self.actionView.favoriteB) {
        event = self.cellData.renderData[@"favorite"];
    } else if (sender == self.actionView.moreB) {
        event = self.cellData.renderData[@"more"];
    } else if (sender == self.actionView.deleteB) {
        event = self.cellData.renderData[@"delete"];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [event performSelector:@selector(fire:) withObject:sender];
    }];
}

- (void)_closeButtonTouched
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_actionsButtonTouched
{
    UIEvent *event = self.cellData.renderData[@"more"];
    [event performSelector:@selector(fire:) withObject:nil];
}

- (void)_fireTapGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([gesture locationInView:self.view].y > self.menuView.top) {
            [self dismissViewControllerAnimated:YES completion:^{
                HSUStatusViewController *statusVC = [[HSUStatusViewController alloc] initWithStatus:self.cellData.rawData];
                [self.viewController.navigationController pushViewController:statusVC animated:YES];
            }];
        }
    }
}

- (void)_fireSwipeDownGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.top = self.height - 17;
        }];
    }
}

- (void)_fireSwipeUpGesture:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.bottom = self.height;
        }];
    }
}

@end
