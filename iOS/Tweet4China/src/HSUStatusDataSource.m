//
//  HSUStatusDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 4/18/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUStatusDataSource.h"

@implementation HSUStatusDataSource

- (id)initWithDelegate:(id<HSUBaseDataSourceDelegate>)delegate status:(NSDictionary *)status
{
    self = [super init];
    if (self) {
        HSUTableCellData *mainCellData = [[HSUTableCellData alloc] initWithRawData:status dataType:kDataType_MainStatus];
        [self.data addObject:mainCellData];
        
        self.delegate = delegate;
        [self.delegate preprocessDataSourceForRender:self];
        
        return self;
        
        // load context data, then call finish on delegate
        dispatch_async(GCDBackgroundThread, ^{
            id result = [twe getDetailsForTweet:status[@"in_reply_to_status_id_str"]];
            if ([result isKindOfClass:[NSError class]]) {
                
            } else {
                L(result);
            }
        });
    }
    return self;
}

@end
