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
@interface HSUBaseDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, assign) NSInteger count;
@property (nonatomic, weak) id<HSUBaseDataSourceDelegate> delegate;
@property (nonatomic, readonly) NSArray *allData;
@property (nonatomic, strong) NSMutableArray *data;

- (NSDictionary *)cellDataAtIndex:(NSInteger)index;
- (NSMutableDictionary *)dataAtIndex:(NSInteger)index;
- (void)setTarget:(id)target forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setAction:(SEL)action forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setEvents:(UIControlEvents)events forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setTarget:(id)target action:(SEL)action events:(UIControlEvents)events forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setTarget:(id)target forKey:(NSString *)key;
- (void)setAction:(SEL)action forKey:(NSString *)key;
- (void)setEvents:(UIControlEvents)events forKey:(NSString *)key;
- (void)setTarget:(id)target action:(SEL)action events:(UIControlEvents)events forKey:(NSString *)key;

- (void)refresh;
- (void)loadMore;
- (void)loadFromIndex:(NSInteger)startIndex toIndex:(NSInteger)endIndex;

@end


@protocol HSUBaseDataSourceDelegate <NSObject>

- (void)dataSource:(HSUBaseDataSource *)dataSource didFinishUpdateWithError:(NSError *)error;

@end