//
//  HSUGalleryStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/28/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "HSUGalleryStatusCell.h"
#import "HSUStatusView.h"

#define padding_S 10

@implementation HSUGalleryStatusCell
{
    HSUStatusView *statusView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        
        statusView = [[HSUStatusView alloc] initWithFrame:ccr(0, padding_S, self.contentView.width, 0)
                                                    style:HSUStatusViewStyle_Gallery];
        [self.contentView addSubview:statusView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    statusView.frame = ccr(0, statusView.top, self.contentView.width, self.contentView.height-padding_S*2);
}

- (void)setupWithData:(HSUTableCellData *)data
{
    [super setupWithData:data];
    
    [statusView setupWithData:data];
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    [data.renderData removeObjectForKey:@"height"];
    return [HSUStatusView heightForData:data constraintWidth:[HSUCommonTools winWidth]-padding_S*2];
}

@end
