//
//  HSUBaseDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRequestDataCount 200

@protocol HSUBaseDataSourceDelegate;
@class HSUTableCellData;
@class HSUUIEvent;
@class FHSTwitterEngine;
@interface HSUBaseDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) FHSTwitterEngine *twEngine;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) id<HSUBaseDataSourceDelegate> delegate;
@property (nonatomic, readonly) NSArray *allData;
@property (atomic, strong) NSMutableArray *data;
@property (atomic, readonly) NSArray *cacheData;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

- (NSDictionary *)rawDataAtIndex:(NSInteger)index;
- (NSMutableDictionary *)renderDataAtIndex:(NSInteger)index;
- (HSUTableCellData *)dataAtIndex:(NSInteger)index;
- (void)addEvent:(HSUUIEvent *)event;

- (void)checkUnread;
- (void)refresh;
- (void)loadMore;
- (void)saveCache;
+ (id)dataSource;
+ (NSString *)cacheKey;
- (void)authenticate;

@end


@protocol HSUBaseDataSourceDelegate <NSObject>

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error;
- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishLoadMoreWithError:(NSError *)error;
- (void)dataSourceDidFindUnread:(HSUBaseDataSource *)dataSource;

@end