//
//  HSUTableCellData.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUTableCellData.h"

@implementation HSUTableCellData

- (id)init
{
    self = [super init];
    if (self) {
        self.renderData = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithRawData:(NSDictionary *)rawData dataType:(NSString *)dataType
{
    self = [self init];
    if (self) {
        self.dataType = dataType;
        self.rawData = rawData;
    }
    return self;
}

- (id)initWithCacheData:(NSDictionary *)cacheData
{
    self = [self init];
    if (self) {
        self.dataType = cacheData[@"data_type"];
        self.rawData = cacheData[@"raw_data"];
    }
    return self;
}

- (NSDictionary *)cacheData
{
    return @{@"data_type": self.dataType, @"raw_data": self.rawData};
}

- (UIEvent *)eventWithName:(NSString *)name
{
    return self.renderData[name];
}

@end
