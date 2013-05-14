//
//  NSData+MD5.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/14/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "NSData+md5.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSData (Md5)

- (NSString *)md5
{
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5(self.bytes, self.length, digest);
    
	NSString *hashed = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        digest[0], digest[1],
                        digest[2], digest[3],
                        digest[4], digest[5],
                        digest[6], digest[7],
                        digest[8], digest[9],
                        digest[10], digest[11],
                        digest[12], digest[13],
                        digest[14], digest[15]];
    return hashed;
}

@end