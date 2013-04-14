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

- (void)setupControl:(UIControl *)control forKey:(NSString *)key withData:(HSUTableCellData *)data cleanOldEvents:(BOOL)clean
{
    HSUUIEvent *event = data.renderData[key];
    if (clean) {
        [control removeTarget:nil action:NULL forControlEvents:event.events];
    }
    [control addTarget:event action:@selector(fire:) forControlEvents:event.events];
}

- (void)setupWithData:(HSUTableCellData *)data
{
    self.data = data;
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return 0;
}

@end
