//
//  HSUTexturedView.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/3/13.
//  Copyright (c) 2013 Jason Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSUTexturedView : UIView

@property (nonatomic, strong) UIImage *texture;

- (id)initWithFrame:(CGRect)frame texture:(UIImage *)texture;

@end
