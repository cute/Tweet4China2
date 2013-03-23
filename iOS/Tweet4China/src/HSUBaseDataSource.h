//
//  HSUBaseDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HSUBaseDataSourceDelegate;
@class HSUEnumerationItem;
@class HSUTableCellData;
@class HSUUIEvent;
@interface HSUBaseDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) id<HSUBaseDataSourceDelegate> delegate;
@property (nonatomic, readonly) NSArray *allData;
@property (atomic, strong) NSMutableArray *data;
@property (atomic, readonly) NSArray *cacheData;

- (NSDictionary *)rawDataAtIndex:(NSInteger)index;
- (NSMutableDictionary *)renderDataAtIndex:(NSInteger)index;
- (HSUTableCellData *)dataAtIndex:(NSInteger)index;
- (void)addEvent:(HSUUIEvent *)event;

- (void)refresh;
- (void)loadMore;
- (void)loadFromIndex:(NSInteger)startIndex toIndex:(NSInteger)endIndex;
- (void)saveCache;
+ (id)dataSource;
+ (NSString *)cacheKey;

@end


@protocol HSUBaseDataSourceDelegate <NSObject>

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishUpdateWithError:(NSError *)error;

@end