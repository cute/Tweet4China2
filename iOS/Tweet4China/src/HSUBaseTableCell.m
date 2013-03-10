//
//  HSUBaseTableCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseTableCell.h"

@implementation HSUBaseTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupControl:(UIControl *)control forKey:(NSString *)key withData:(NSDictionary *)data
{
    id target = data[[NSString stringWithFormat:@"%@_t", key]];
    if (target == nil) {
        target = self.defaultActionTarget;
    }
    SEL action = NSSelectorFromString(data[[NSString stringWithFormat:@"%@_a", key]]);
    UIControlEvents events = [data[[NSString stringWithFormat:@"%@_e", key]] intValue];
    if (events == 0) {
        events = self.defaultActionEvents;
    }
    [control addTarget:control action:action forControlEvents:events];
}

- (void)setupWithData:(NSDictionary *)data atIndex:(NSInteger)index
{
    
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    return 0;
}

@end
