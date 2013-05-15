//
//  HSUDraftTableCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUDraftCell.h"

@implementation HSUDraftCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return 44;
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    self.textLabel.text = data.rawData[@"title"];
    self.detailTextLabel.text = data.rawData[@"status"];
    self.backgroundColor = kWhiteColor;
    self.contentView.backgroundColor = kClearColor;
    self.textLabel.backgroundColor = kClearColor;
}

@end
