//
//  HSUMessageViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUMessagesViewController.h"
#import "HSUMessagesDataSource.h"
#import "HSUSendBarButtonItem.h"

@interface HSUMessagesViewController () <UITextViewDelegate>

@property (nonatomic, weak) UIImageView *toolbar;
@property (nonatomic, weak) UIImageView *textViewBackground;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UILabel *wordCountLabel;
@property (nonatomic, assign) float keyboardHeight;
@property (nonatomic, assign) BOOL layoutForTextChanged;

@property (nonatomic, strong) UIBarButtonItem *actionsBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *sendBarButtonItem;

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
    [backButton setTapTarget:self action:@selector(backButtonTouched)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIButton *actionsButton = [[UIButton alloc] init];
    [actionsButton setImage:[UIImage imageNamed:@"icn_nav_bar_light_actions"] forState:UIControlStateNormal];
    [actionsButton sizeToFit];
    actionsButton.width *= 1.4;
    actionsButton.showsTouchWhenHighlighted = YES;
    [actionsButton setTapTarget:self action:@selector(_actionsButtonTouched)];
    self.actionsBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:actionsButton];
    self.navigationItem.rightBarButtonItem = self.actionsBarButtonItem;
    
    UIBarButtonItem *sendButtonItem = [[HSUSendBarButtonItem alloc] init];
    self.sendBarButtonItem = sendButtonItem;
    sendButtonItem.title = @"Send";
    sendButtonItem.target = self;
    sendButtonItem.action = @selector(_sendButtonTouched);
    sendButtonItem.enabled = NO;
    
    UIImageView *toolbar = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"direct-message-bar"] stretchableImageFromCenter]];
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
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.textView.width == 0) {
        if (self.textView.hasText) {
            self.textView.size = ccs(275, 0);
        } else {
            self.textView.size = ccs(310, 0);
        }
    } else {
        if (self.textView.hasText) {
            self.textView.width = 275;
        } else {
            self.textView.width = 310;
        }
    }
    CGSize textViewSize = self.textView.contentSize;
    if (textViewSize.height > 100) {
        textViewSize = ccs(textViewSize.width, 100);
    }
    CGSize textViewBackgroundSize = ccs(textViewSize.width, textViewSize.height-8);
    CGSize toolbarSize = ccs(self.width, textViewBackgroundSize.height+9+7);
    __weak typeof(&*self)weakSelf = self;
    void (^animatedBlock)() = ^{
        weakSelf.tableView.height = weakSelf.height - weakSelf.keyboardHeight - toolbarSize.height;
        weakSelf.toolbar.size = toolbarSize;
        weakSelf.toolbar.bottom = weakSelf.height - weakSelf.keyboardHeight;
        weakSelf.textViewBackground.leftTop = ccp(5, weakSelf.toolbar.top + 9);
        weakSelf.textViewBackground.size = textViewBackgroundSize;
        weakSelf.textView.size = textViewSize;
        weakSelf.textView.leftTop = ccp(12, weakSelf.tableView.bottom+5);
        weakSelf.wordCountLabel.rightCenter = ccp(weakSelf.width-10, weakSelf.toolbar.rightCenter.y);
    };
    if (self.viewDidAppearCount == 0 || self.layoutForTextChanged) {
        self.layoutForTextChanged = NO;
        animatedBlock();
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            animatedBlock();
            [weakSelf _scrollToBottom];
        } completion:^(BOOL finished) {
            weakSelf.navigationItem.rightBarButtonItem = weakSelf.sendBarButtonItem;
        }];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.textView.hasText) {
        self.wordCountLabel.text = S(@"%u", 140-self.textView.text.length);
        self.sendBarButtonItem.enabled = YES;
    } else {
        self.wordCountLabel.text = nil;
        self.sendBarButtonItem.enabled = NO;
    }
    [self.wordCountLabel sizeToFit];
    self.layoutForTextChanged = YES;
    [self.view setNeedsLayout];
}

- (void)preprocessDataSourceForRender:(HSUBaseDataSource *)dataSource
{
    [super preprocessDataSourceForRender:dataSource];
    
    [dataSource addEventWithName:@"retry" target:self action:@selector(retry:) events:UIControlEventTouchUpInside];
}

- (void)_scrollToBottom
{
    [self.tableView setContentOffset:ccp(0, MAX(self.tableView.contentSize.height-self.tableView.height, 0)) animated:YES];
}

- (void)backButtonTouched
{
    // todo
    if (self.textView.hasText) {
        notification_post_with_object(kNNConversationBackWithIncompletedSending, @[((HSUMessagesDataSource *)self.dataSource).conversation, self.textView.text]);
    }
    [super backButtonTouched];
}

- (void)_actionsButtonTouched
{
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    RIButtonItem *mailItem = [RIButtonItem itemWithLabel:@"Mail Conversation"];
    mailItem.action = ^{
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Forget it"];
        RIButtonItem *feedbackItem = [RIButtonItem itemWithLabel:@"Feedback"];
        feedbackItem.action = ^{
            [HSUCommonTools sendMailWithSubject:@"[Feedback][Tweet4China][New Feature]" body:@"I need feature \"Mail direct message conversation\"" presentFromViewController:self];
        };
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"擦，这个功能还有人用啊！我用不到，所以就没做!==如果你确实需要这个功能请反馈给我。" cancelButtonItem:cancelItem otherButtonItems:feedbackItem, nil];
        [alert show];
    };
    RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Delete conversation"];
    deleteItem.action = ^{
        RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
        RIButtonItem *deleteItem = [RIButtonItem itemWithLabel:@"Delete conversation"];
        deleteItem.action = ^{
            [self.navigationController popViewControllerAnimated:YES];
            [((HSUMessagesDataSource *)self.dataSource) deleteConversation];
        };
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:deleteItem otherButtonItems:nil, nil];
        [actionSheet showInView:self.view.window];
    };
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:deleteItem otherButtonItems:mailItem, nil];
    [actionSheet showInView:self.view.window];
}

- (void)_sendButtonTouched
{
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    message[@"sender"] = self.myProfile;
    message[@"recipient"] = self.herProfile;
    message[@"sender_id"] = self.myProfile[@"id"];
    message[@"sender_id_str"] = self.myProfile[@"id_str"];
    message[@"sender_screen_name"] = self.myProfile[@"screen_name"];
    message[@"recipient_id"] = self.herProfile[@"id"];
    message[@"recipient_id_str"] = self.herProfile[@"id_str"];
    message[@"recipient_screen_name"] = self.herProfile[@"screen_name"];
    message[@"text"] = self.textView.text;
    message[@"sending"] = @(YES);
    HSUTableCellData *appendingCellData = [[HSUTableCellData alloc] initWithRawData:message dataType:kDataType_Message];
    [self.dataSource.data addObject:appendingCellData];
    [self preprocessDataSourceForRender:self.dataSource];
    [self _retrySendMessage:message];
    self.textView.text = nil;
    [self textViewDidChange:self.textView];
    [self _scrollToBottom];
}

- (void)retry:(HSUTableCellData *)cellData
{
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    RIButtonItem *retryItem = [RIButtonItem itemWithLabel:@"Retry send"];
    retryItem.action = ^{
        NSMutableDictionary *message = cellData.rawData.mutableCopy;
        cellData.rawData = message;
        [self _retrySendMessage:message];
    };
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Message failed to send" cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:retryItem, nil];
    [actionSheet showInView:self.view.window];
}

- (void)_retrySendMessage:(NSMutableDictionary *)message
{
    [message removeObjectForKey:@"failed"];
    [self.tableView reloadData];
    dispatch_async(GCDBackgroundThread, ^{
        id result = [TWENGINE sendDirectMessage:message[@"text"] toUser:message[@"recipient_screen_name"] isID:NO];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_sync(GCDMainThread, ^{
            @autoreleasepool {
                __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                if ([TWENGINE dealWithError:result errTitle:@"Failed to send message"]) {
                    [message setValuesForKeysWithDictionary:result];
                    [message removeObjectForKey:@"sending"];
                    [strongSelf.tableView reloadData];
                } else {
                    message[@"failed"] = @(YES);
                    [strongSelf.tableView reloadData];
                }
            }
        });
    });
}

@end
