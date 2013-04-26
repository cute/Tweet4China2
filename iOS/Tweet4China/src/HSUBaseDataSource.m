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

- (void)addEventWithName:(NSString *)name target:(id)target action:(SEL)action events:(UIControlEvents)events
{
    for (uint i=0; i<self.count; i++) {
        HSUUIEvent *cellEvent = [[HSUUIEvent alloc] initWithName:name target:target action:action events:events];
        cellEvent.cellData = [self dataAtIndex:i];
        [self renderDataAtIndex:i][name] = cellEvent;
    }
}

- (void)checkUnread
{
    [HSUNetworkActivityIndicatorManager oneMore];
}

- (void)refresh
{
    self.loadingCount ++;
	[HSUNetworkActivityIndicatorManager oneMore];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNNStartRefreshing object:nil];
}

- (void)loadMore
{
    self.loadingCount ++;
    [HSUNetworkActivityIndicatorManager oneMore];
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
    [[NSUserDefaults standardUserDefaults] setObject:cacheDataArr forKey:self.class.cacheKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

@end
