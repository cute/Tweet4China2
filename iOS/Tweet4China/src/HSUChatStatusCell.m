//
//  HSUConversationStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/12/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUChatStatusCell.h"
#import "HSUStatusView.h"

@implementation HSUChatStatusCell

+ (HSUStatusViewStyle)statusStyle
{
    return HSUStatusViewStyle_Chat;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = bw(245);
    }
    return self;
}

@end
