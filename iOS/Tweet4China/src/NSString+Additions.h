//
//  NSString+Additions.h
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

+ (instancetype)stringSplitWithCommaFromInteger:(NSInteger)intVal;

- (NSString *)reversedString;
- (NSString *)twitterScreenName;

@end
