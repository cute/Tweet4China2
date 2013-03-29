//
//  HSUComposeViewController.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/26/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUComposeViewController.h"

@interface HSUComposeViewController ()

@end

@implementation HSUComposeViewController
{
    UITextField *contentTF;
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    contentTF = [[UITextField alloc] init];
    contentShadowV = [UIImageView viewNamed:@""];
    toolbar = [[UIView alloc] init];
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

@end
