//
//  HSUUIEvent.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSUTableCellData;
@interface HSUUIEvent : NSObject

- (id)initWithName:(NSString *)name target:(id)target action:(SEL)action events:(UIControlEvents)events;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) UIControlEvents events;
@property (nonatomic, weak) HSUTableCellData *cellData;

- (void)fire:(id)sender;

@end
