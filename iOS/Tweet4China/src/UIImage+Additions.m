//
// Created by jason on 4/4/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UIImage+Additions.h"


@implementation UIImage (Additions)

- (UIImage *)stretchableImageFromCenter {
    return [self stretchableImageWithLeftCapWidth:self.size.width/2 topCapHeight:self.size.height/2];
}


@end