//
//  HSUTableCellData.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HSUUIEvent;
@interface HSUTableCellData : NSObject

- (id)initWithCacheData:(NSDictionary *)cacheData;
- (id)initWithRawData:(NSDictionary *)rawData dataType:(NSString *)dataType;

@property (nonatomic, readonly) NSString *dataType;
@property (nonatomic, strong) NSDictionary *rawData;
@property (nonatomic, strong) NSMutableDictionary *renderData;
@property (nonatomic, readonly) NSDictionary *cacheData;

- (UIEvent *)eventWithName:(NSString *)name;

@end
