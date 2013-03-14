//
//  HSUStatusCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusCell.h"

@implementation HSUStatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setupWithData:(NSDictionary *)data
{
    [super setupWithData:data];
    self.textLabel.text = [NSString stringWithFormat:@"%@: %@", data[@"user"][@"name"], data[@"text"]];
    self.textLabel.font = [UIFont systemFontOfSize:12];
    self.textLabel.numberOfLines = 3;
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    NSString *text = [NSString stringWithFormat:@"%@: %@", data[@"user"][@"name"], data[@"text"]];
    return [text sizeWithFont:[UIFont systemFontOfSize:12]].width / 320 * 15 + 15;
}

@end
