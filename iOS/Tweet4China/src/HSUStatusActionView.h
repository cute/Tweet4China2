//
//  HSUStatusActionView.h
//  Tweet4China
//
//  Created by Jason Hsu on 4/27/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HSUStatusActionViewStyle) {
    HSUStatusActionViewStyle_Default = 0,
    HSUStatusActionViewStyle_Gallery = 1,
};

@interface HSUStatusActionView : UIView

@property (nonatomic, strong) UIButton *replayB, *retweetB, *favoriteB, *moreB, *deleteB;

- (id)initWithStatus:(NSDictionary *)status style:(HSUStatusActionViewStyle)style;

@end
