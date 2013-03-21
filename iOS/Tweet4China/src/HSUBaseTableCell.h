//
//  HSUBaseTableCell.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUBaseTableCell : UITableViewCell

@property (nonatomic, weak) id defaultActionTarget;
@property (nonatomic, assign) UIControlEvents defaultActionEvents;

- (void)setupWithData:(NSMutableDictionary *)data;
+ (CGFloat)heightForData:(NSMutableDictionary *)data;
- (void)setupControl:(UIControl *)control forKey:(NSString *)key withData:(NSDictionary *)data;

@end
