//
//  HSUBaseTableCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseTableCell.h"

@implementation HSUBaseTableCell
{
    NSMutableDictionary *handlers;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupControl:(UIControl *)control forKey:(NSString *)key withData:(HSUTableCellData *)data
{
    NSDictionary *renderData = data.renderData;
    HSUUIEvent *event = renderData[key];
    [control addTarget:event.target action:event.action forControlEvents:event.events];
}

- (void)setupWithData:(HSUTableCellData *)data
{
    
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return 0;
}

@end
