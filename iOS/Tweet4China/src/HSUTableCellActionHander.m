//
//  HSUTableCellActionHander.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTableCellActionHander.h"
@interface HSUTableCellActionHander()

@property (nonatomic, weak) id sender;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) UIControlEvents events;
@property (nonatomic, weak) NSDictionary *cellData;

@end

@implementation HSUTableCellActionHander

- (id)initWithSender:(UIControl *)sender target:(id)target action:(SEL)action events:(UIControlEvents)events cellData:(NSDictionary *)cellData actionName:(NSString *)actionName
{
    self = [super init];
    if (self) {
        self.sender = sender;
        self.target = target;
        self.action = action;
        self.events = events;
        self.cellData = cellData;
        
        [sender addTarget:self action:@selector(doAction) forControlEvents:events];
    }
    return self;
}

- (void)doAction
{
    if ([self.target respondsToSelector:self.action]) {
        [self.target performSelector:self.action withObject:self.cellData];
    }
}

@end
