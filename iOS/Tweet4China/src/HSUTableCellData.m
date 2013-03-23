//
//  HSUTableCellData.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTableCellData.h"

@implementation HSUTableCellData

- (id)initWithCacheData:(NSDictionary *)cacheData
{
    self = [super init];
    if (self) {
        self.rawData = cacheData[@"raw_data"];
        self.renderData = [cacheData[@"render_data"] mutableCopy];
    }
    return self;
}

- (UIEvent *)eventWithName:(NSString *)name
{
    return self.renderData[name];
}

- (NSDictionary *)cacheData
{
    NSDictionary *renderData = @{@"data_type": self.renderData[@"data_type"]};
    NSDictionary *cacheDict = @{@"raw_data": self.rawData,
                                @"render_data": renderData};
    return cacheDict;
}

- (NSString *)dataType
{
    return self.renderData[@"data_type"];
}

@end
