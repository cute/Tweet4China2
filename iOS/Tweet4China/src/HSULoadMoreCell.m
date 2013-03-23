//
//  HSULoadMoreCell.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSULoadMoreCell.h"

@implementation HSULoadMoreCell
{
    UIImageView *icon;
    UIActivityIndicatorView *spinner;
    UILabel *title;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = kWhiteColor;
        
        icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_inset_larry"]];
        [self.contentView addSubview:icon];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:spinner];
        
        title = [[UILabel alloc] init];
        [self.contentView addSubview:title];
        title.text = @"Network Error";
        [title sizeToFit];
        // todo: set title styles
    }
    return self;
}

- (void)setupWithData:(HSUTableCellData *)data
{
    NSInteger status = [data.renderData[@"status"] integerValue];
    if (status == kLoadMoreCellStatus_Done) {
        icon.hidden = NO;
        [spinner stopAnimating]; spinner.hidden = YES;
        title.hidden = YES;
    } else if (status == kLoadMoreCellStatus_Loading) {
        icon.hidden = YES;
        spinner.hidden = NO; [spinner startAnimating];
        title.hidden = YES;
    } else if (status == kLoadMoreCellStatus_Error) {
        icon.hidden = YES;
        title.hidden = NO;
        [spinner stopAnimating]; spinner.hidden = YES;
    }
}

+ (CGFloat)heightForData:(HSUTableCellData *)data
{
    return kLoadMoreCellHeight;
}

- (void)layoutSubviews
{
    icon.center = self.contentView.center;
    spinner.center = self.contentView.center;
    title.center = self.contentView.center;
}

@end
