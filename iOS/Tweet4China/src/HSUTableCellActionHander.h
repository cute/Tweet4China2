//
//  HSUTableCellActionHander.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HSUTableCellActionHander : NSObject

- (id)initWithSender:(UIControl *)sender target:(id)target action:(SEL)action events:(UIControlEvents)events cellData:(NSDictionary *)cellData actionName:(NSString *)actionName;

@end
