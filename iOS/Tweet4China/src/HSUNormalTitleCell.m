//
//  HSUNormalTitleCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUNormalTitleCell.h"

@implementation HSUNormalTitleCell

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return 44;
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    self.textLabel.text = data.rawData[@"title"];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.backgroundColor = kWhiteColor;
    self.contentView.backgroundColor = kClearColor;
    self.textLabel.backgroundColor = kClearColor;
}

@end
