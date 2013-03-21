//
//  HSUBaseDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"
#import "HSUBaseTableCell.h"
#import "UIAlertView+Blocks.h"

@implementation HSUBaseDataSource

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.data = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dataForRow = [self dataAtIndex:indexPath.row];
    NSString *dataType = dataForRow[@"render_data"][@"data_type"];
    HSUBaseTableCell *cell = (HSUBaseTableCell *)[tableView dequeueReusableCellWithIdentifier:dataType];
    [cell setupWithData:dataForRow];
    cell.defaultActionTarget = tableView.delegate;
    cell.defaultActionEvents = UIControlEventTouchUpInside;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - Data
- (NSArray *)allData
{
    return self.data;
}

- (NSMutableDictionary *)dataAtIndex:(NSInteger)index
{
    if (self.data.count > index) {
        return self.data[index];
    }
    // Warn
    return nil;
}

- (NSInteger)count
{
    return self.data.count;
}

- (NSDictionary *)cellDataAtIndex:(NSInteger)index
{
    return [self dataAtIndex:index][@"cell_data"];
}

- (void)setTarget:(id)target forKey:(NSString *)key atIndex:(NSInteger)index
{
    NSMutableDictionary *cellData = [self dataAtIndex:index];
    cellData[[NSString stringWithFormat:@"%@_t", key]] = target;
}

- (void)setAction:(SEL)action forKey:(NSString *)key atIndex:(NSInteger)index
{
    NSMutableDictionary *cellData = [self dataAtIndex:index];
    cellData[[NSString stringWithFormat:@"%@_a", key]] = NSStringFromSelector(action);
}

- (void)setEvents:(UIControlEvents)events forKey:(NSString *)key atIndex:(NSInteger)index
{
    NSMutableDictionary *cellData = [self dataAtIndex:index];
    cellData[[NSString stringWithFormat:@"%@_e", key]] = [NSNumber numberWithInteger:events];
}

- (void)setTarget:(id)target action:(SEL)action events:(UIControlEvents)events forKey:(NSString *)key atIndex:(NSInteger)index
{
    [self setTarget:target forKey:key atIndex:index];
    [self setAction:action forKey:key atIndex:index];
    [self setEvents:events forKey:key atIndex:index];
}

- (void)setTarget:(id)target forKey:(NSString *)key
{
    for (int i=0; i<self.count; i++) {
        [self setTarget:target forKey:key atIndex:i];
    }
}

- (void)setAction:(SEL)action forKey:(NSString *)key
{
    for (int i=0; i<self.count; i++) {
        [self setAction:action forKey:key atIndex:i];
    }
}

- (void)setEvents:(UIControlEvents)events forKey:(NSString *)key
{
    for (int i=0; i<self.count; i++) {
        [self setEvents:events forKey:key atIndex:i];
    }
}

- (void)setTarget:(id)target action:(SEL)action events:(UIControlEvents)events forKey:(NSString *)key
{
    for (int i=0; i<self.count; i++) {
        [self setTarget:target action:action events:events forKey:key atIndex:i];
    }
}

- (void)refresh
{
    
}

- (void)loadMore
{
    
}

- (void)loadFromIndex:(NSInteger)startIndex toIndex:(NSInteger)endIndex
{
    
}

- (NSArray *)cacheData
{
    uint count = MIN(self.count, 200);
    NSMutableArray *cacheData = [NSMutableArray arrayWithCapacity:200];
    for (uint i=0; i<count; i++) {
        NSDictionary *rowData = [self dataAtIndex:i];
        NSDictionary *cellData = rowData[@"cell_data"];
        NSDictionary *renderData = @{@"data_type": rowData[@"render_data"][@"data_type"]};
        NSDictionary *cacheRowData = @{@"cell_data": cellData, @"render_data": renderData};
        [cacheData addObject:cacheRowData];
    }
    return cacheData;
}

- (void)saveCache
{
    [[NSUserDefaults standardUserDefaults] setObject:self.cacheData forKey:self.class.cacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)cacheKey
{
    return self.description.lowercaseString;
}

+ (id)dataSource
{
    HSUBaseDataSource *dataSource = [[self alloc] init];
    NSArray *data = [[NSUserDefaults standardUserDefaults] arrayForKey:self.cacheKey];
    if (data) {
        NSMutableArray *mData = [@[] mutableCopy];
        for (NSDictionary *dataRow in data) {
            NSDictionary *newData = @{@"cell_data": dataRow[@"cell_data"],
                                      @"render_data": [dataRow[@"render_data"] mutableCopy]};
            [mData addObject:newData];
        }
        dataSource.data = mData;
    }
    return dataSource;
}

@end
