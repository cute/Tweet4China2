//
//  HSUBaseDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 3/10/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUBaseDataSource.h"
#import "HSUBaseTableCell.h"

@implementation HSUBaseDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.requestCount = 200;
        self.data = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)authenticate
{
    if (!TWENGINE.isAuthorized) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserSettings_DBKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [TWENGINE auth];
    } else {
        id userSettings = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey];
        if (!userSettings) {
            UIAlertView *loadingAlert = [[UIAlertView alloc] initWithTitle:@"Loading account info..." message:nil cancelButtonItem:nil otherButtonItems:nil, nil];
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [loadingAlert addSubview:spinner];
            spinner.frame = ccr(125, 50, 30, 30);
            [loadingAlert show];
            userSettings = [TWENGINE getUserSettings];
            if ([TWENGINE dealWithError:userSettings errTitle:@"Fetch account info failed"]) {
                [[NSUserDefaults standardUserDefaults] setObject:userSettings forKey:kUserSettings_DBKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [loadingAlert dismissWithClickedButtonIndex:-1 animated:YES];
            }
        }
    }
}

#pragma mark - TableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.loadingCount && self.count > 1) {
        HSUTableCellData *cellData = [self dataAtIndex:indexPath.row];
        if ([cellData.dataType isEqualToString:kDataType_LoadMore]) {
            cellData.renderData[@"status"] = @(kLoadMoreCellStatus_Loading);
            [self loadMore];
        }
    }
    
    HSUTableCellData *cellData = [self dataAtIndexPath:indexPath];
    HSUBaseTableCell *cell = (HSUBaseTableCell *)[tableView dequeueReusableCellWithIdentifier:cellData.dataType];
    [cell setupWithData:cellData];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.data.count;
    }
    return 0;
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

- (HSUTableCellData *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        return nil;
    }
    return [self dataAtIndex:indexPath.row];
}

- (NSMutableDictionary *)renderDataAtIndex:(NSInteger)index;
{
    return [self dataAtIndex:index].renderData;
}

- (NSMutableDictionary *)renderDataAtIndexPath:(NSIndexPath *)indexPath
{
    return [self dataAtIndexPath:indexPath].renderData;
}

- (NSInteger)count
{
    return self.data.count;
}

- (NSDictionary *)rawDataAtIndex:(NSInteger)index
{
    return [self dataAtIndex:index].rawData;
}

- (NSDictionary *)rawDataAtIndexPath:(NSIndexPath *)indexPath
{
    return [self dataAtIndexPath:indexPath].rawData;
}

- (void)addEventWithName:(NSString *)name target:(id)target action:(SEL)action events:(UIControlEvents)events
{
    for (uint i=0; i<self.count; i++) {
        HSUUIEvent *cellEvent = [[HSUUIEvent alloc] initWithName:name target:target action:action events:events];
        cellEvent.cellData = [self dataAtIndex:i];
        [self renderDataAtIndex:i][name] = cellEvent;
    }
}

- (void)refresh
{
    self.loadingCount ++;
    notification_post(kNNStartRefreshing);
}

- (void)loadMore
{
    self.loadingCount ++;
}

- (void)loadFromIndex:(NSInteger)startIndex toIndex:(NSInteger)endIndex
{
    
}

- (void)saveCache
{
    uint cacheSize = kRequestDataCountViaWifi;
    NSMutableArray *cacheDataArr = [NSMutableArray arrayWithCapacity:cacheSize];
    for (HSUTableCellData *cellData in self.data) {
        if (cacheDataArr.count < cacheSize) {
            [cacheDataArr addObject:cellData.cacheData];
        } else {
            break;
        }
    }
    if (cacheDataArr.count) {
        [[NSUserDefaults standardUserDefaults] setObject:cacheDataArr forKey:self.class.cacheKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSString *)cacheKey
{
    return self.description.lowercaseString;
}

+ (id)dataSourceWithDelegate:(id<HSUBaseDataSourceDelegate>)delegate useCache:(BOOL)useCahce
{
    HSUBaseDataSource *dataSource = [[self alloc] init];
    dataSource.delegate = delegate;
    // TODO crash reset policy
//    return dataSource;
    if (useCahce) {
        NSArray *cacheDataArr = [[NSUserDefaults standardUserDefaults] arrayForKey:self.cacheKey];
        if (cacheDataArr) {
            NSMutableArray *mData = [NSMutableArray arrayWithCapacity:cacheDataArr.count];
            for (NSDictionary *cacheData in cacheDataArr) {
                [mData addObject:[[HSUTableCellData alloc] initWithCacheData:cacheData]];
            }
            dataSource.data = mData;
        }
        [dataSource.delegate preprocessDataSourceForRender:dataSource];
    }
    return dataSource;
}

- (void)removeCellData:(HSUTableCellData *)cellData
{
    [self.data removeObject:cellData];
}

@end
