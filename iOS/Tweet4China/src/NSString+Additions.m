//
//  NSString+Additions.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (instancetype)stringSplitWithCommaFromInteger:(NSInteger)intVal
{
    NSString *str = [NSString stringWithFormat:@"%@", @(intVal)];
    NSMutableString *ret = [[NSMutableString alloc] init];
    
    int len = str.length;
    
    while (len > 0) {
        [ret appendString:[NSString stringWithFormat:@"%C", [str characterAtIndex:--len]]];
        if ((str.length - len) % 3 == 0) {
            [ret appendString:@","];
        }
    }
    
    return [ret reversedString];
}

- (NSString *)reversedString
{
    NSMutableString *reversedStr;
    int len = self.length;
    
    reversedStr = [NSMutableString stringWithCapacity:len];
    
    while (len > 0)
        [reversedStr appendString:[NSString stringWithFormat:@"%C", [self characterAtIndex:--len]]];
    
    return reversedStr;
}

- (NSString *)twitterScreenName
{
    return [NSString stringWithFormat:@"@%@", self];
}

@end
