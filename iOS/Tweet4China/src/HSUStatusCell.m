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


- (void)setupWithData:(NSMutableDictionary *)data atIndex:(NSInteger)index
{
    [super setupWithData:data atIndex:index];
}

+ (CGFloat)heightForData:(NSDictionary *)data
{
    return 0;
}

@end
