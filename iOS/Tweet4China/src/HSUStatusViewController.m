//
//  HSUStatusViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusViewController.h"
#import "HSUStatusDataSource.h"
#import "HSUMainStatusCell.h"
#import "HSUComposeViewController.h"
#import "HSUGalleryView.h"
#import "HSUMiniBrowser.h"
#import "HSUNavigationBarLight.h"

@interface HSUStatusViewController ()

@property (nonatomic, strong) NSDictionary *mainStatus;

@end

@implementation HSUStatusViewController

- (id)initWithStatus:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        self.mainStatus = status;
        self.dataSourceClass = [HSUStatusDataSource class];
        self.useRefreshControl = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    self.dataSource = [[self.dataSourceClass alloc] initWithDelegate:self status:self.mainStatus];
    self.dataSource.delegate = self;
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[HSUMainStatusCell class] forCellReuseIdentifier:kDataType_MainStatus];
}

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error
{
    [super dataSource:dataSource didFinishRefreshWithError:error];
}


- (void)_composeButtonTouched
{
    HSUComposeViewController *composeVC = [[HSUComposeViewController alloc] init];
    NSMutableString *defaultText = [[NSMutableString alloc] init];
    HSUTableCellData *mainStatus = [self.dataSource dataAtIndex:0];
    NSString *authorScreenName = mainStatus.rawData[@"user"][@"screen_name"];
    composeVC.defaultTitle = S(@"Reply to @%@", authorScreenName);
    NSString *statusId = mainStatus.rawData[@"id_str"];
    composeVC.inReplyToStatusId = statusId;
    NSArray *userMentions = mainStatus.rawData[@"entities"][@"user_mentions"];
    if (userMentions && userMentions.count) {
        [defaultText appendFormat:@"@%@ ", authorScreenName];
        for (NSDictionary *userMention in userMentions) {
            NSString *screenName = userMention[@"screen_name"];
            [defaultText appendFormat:@"@%@ ", screenName];
        }
        uint start = authorScreenName.length + 2;
        uint length = defaultText.length - authorScreenName.length - 2;
        composeVC.defaultSelectedRange = NSMakeRange(start, length);
    } else {
        [defaultText appendFormat:@" @%@ ", authorScreenName];
    }
    composeVC.defaultText = defaultText;
    UINavigationController *nav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavigationBarLight class] toolbarClass:nil];
    nav.viewControllers = @[composeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)attributedLabelDidLongPressed:(TTTAttributedLabel *)label
{
    label.backgroundColor = rgb(215, 230, 242);
    RIButtonItem *cancelItem = [RIButtonItem itemWithLabel:@"Cancel"];
    cancelItem.action = ^{
        label.backgroundColor = kClearColor;
    };
    RIButtonItem *copyItem = [RIButtonItem itemWithLabel:@"Copy Content"];
    copyItem.action = ^{
        label.backgroundColor = kClearColor;
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = label.text;
    };
    UIActionSheet *linkActionSheet = [[UIActionSheet alloc] initWithTitle:nil cancelButtonItem:cancelItem destructiveButtonItem:nil otherButtonItems:copyItem, nil];
    [linkActionSheet showInView:self.view.window];
}

- (void)openPhotoURL:(NSURL *)photoURL withCellData:(HSUTableCellData *)cellData
{
    HSUGalleryView *galleryView = [[HSUGalleryView alloc] initWithData:cellData imageURL:photoURL];
    [self.view.window addSubview:galleryView];
    [galleryView showWithAnimation:YES];
}

- (void)openWebURL:(NSURL *)webURL withCellData:(HSUTableCellData *)cellData
{
    UINavigationController *nav = [[UINavigationController alloc] initWithNavigationBarClass:[HSUNavigationBarLight class] toolbarClass:nil];
    HSUMiniBrowser *miniBrowser = [[HSUMiniBrowser alloc] initWithURL:webURL cellData:cellData];
    nav.viewControllers = @[miniBrowser];
    [self presentViewController:nav animated:YES completion:nil];
}

@end
