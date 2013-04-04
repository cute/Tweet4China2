//
// Created by jason on 4/5/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIButton+Additions.h"


@implementation UIButton (Additions)

- (void)setTapTarget:(id)target action:(SEL)action
{
    [self removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end