//
//  HSUBaseDataSource.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kRequestDataCountViaWifi 200
#define kRequestDataCountViaWWAN 20

@protocol HSUBaseDataSourceDelegate;
@class HSUTableCellData;
@class HSUUIEvent;
@interface HSUBaseDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) id<HSUBaseDataSourceDelegate> delegate;
@property (nonatomic, readonly) NSArray *allData;
@property (atomic, strong) NSMutableArray *data;
@property (nonatomic, assign, getter = isLoading) BOOL loading;

- (NSDictionary *)rawDataAtIndex:(NSInteger)index;
- (NSMutableDictionary *)renderDataAtIndex:(NSInteger)index;
- (HSUTableCellData *)dataAtIndex:(NSInteger)index;
- (void)addEventWithName:(NSString *)name target:(id)target action:(SEL)action events:(UIControlEvents)events;

- (void)checkUnread;
- (void)refresh;
- (void)loadMore;
- (void)saveCache;
+ (id)dataSourceWithDelegate:(id<HSUBaseDataSourceDelegate>)delegate useCache:(BOOL)useCahce;
+ (NSString *)cacheKey;
- (void)authenticate;

+ (NSUInteger)requestDataCount;

@end


@protocol HSUBaseDataSourceDelegate <NSObject>

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishRefreshWithError:(NSError *)error;
- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishLoadMoreWithError:(NSError *)error;
- (void)dataSourceDidFindUnread:(HSUBaseDataSource *)dataSource;
- (void)preprocessDataSourceForRender:(HSUBaseDataSource *)dataSource;

@end