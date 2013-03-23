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
#import "HSUTableCellData.h"
#import "HSUUIEvent.h"

@implementation HSUBaseDataSource

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
    HSUTableCellData *cellData = [self dataAtIndex:indexPath.row];
    HSUBaseTableCell *cell = (HSUBaseTableCell *)[tableView dequeueReusableCellWithIdentifier:cellData.dataType];
    [cell setupWithData:cellData];
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

- (HSUTableCellData *)dataAtIndex:(NSInteger)index
{
    if (self.data.count > index) {
        return self.data[index];
    }
    // Warn
    return nil;
}

- (NSMutableDictionary *)renderDataAtIndex:(NSInteger)index;
{
    if (self.data.count > index) {
        return [self dataAtIndex:index].renderData;
    }
    return nil;
}

- (NSInteger)count
{
    return self.data.count;
}

- (NSDictionary *)rawDataAtIndex:(NSInteger)index
{
    return [self dataAtIndex:index].rawData;
}

- (void)addEvent:(HSUUIEvent *)event
{
    for (uint i=0; i<self.count; i++) {
        event.cellData = [self dataAtIndex:i];
        [self renderDataAtIndex:i][event.name] = event;
    }
}

- (void)refresh
{
	[HSUNetworkActivityIndicatorManager oneMore];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNNStartRefreshing object:nil];
}

- (void)loadMore
{
    
}

- (void)loadFromIndex:(NSInteger)startIndex toIndex:(NSInteger)endIndex
{
    
}

- (NSArray *)cacheData
{
    NSMutableArray *cacheData = [NSMutableArray arrayWithCapacity:200];
    for (HSUTableCellData *cellData in self.data) {
        if (cacheData.count > 200) {
            break;
        }
        [cacheData addObject:cellData.cacheData];
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
    return dataSource;
    NSArray *data = [[NSUserDefaults standardUserDefaults] arrayForKey:self.cacheKey];
    if (data) {
        NSMutableArray *mData = [@[] mutableCopy];
        for (NSDictionary *dataRow in data) {
            HSUTableCellData *newData = [[HSUTableCellData alloc] initWithCacheData:dataRow];
            [mData addObject:newData];
        }
        dataSource.data = mData;
    }
    return dataSource;
}

@end
