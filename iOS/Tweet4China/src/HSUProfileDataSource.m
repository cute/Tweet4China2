//
//  HSUProfileDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/1/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUProfileDataSource.h"
#import "HSUBaseTableCell.h"

@interface HSUProfileDataSource ()

@property (nonatomic, strong) NSMutableArray *sectionsData;

@end

@implementation HSUProfileDataSource

- (id)init
{
    self = [super init];
    if (self) {
        self.sectionsData = [NSMutableArray arrayWithCapacity:2];
        NSMutableArray *referencesData = [NSMutableArray arrayWithCapacity:4];
        NSString *userScreenName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey][@"screen_name"];
        NSDictionary *rawData = @{@"title": @"Following",
                                  @"action": kAction_Following,
                                  @"user_screen_name": userScreenName};
        HSUTableCellData *followingCellData = [[HSUTableCellData alloc] initWithRawData:rawData
                                                                               dataType:kDataType_NormalTitle];
        rawData = @{@"title": @"Followers",
                    @"action": kAction_Followers,
                    @"user_screen_name": userScreenName};
        HSUTableCellData *followersCellData = [[HSUTableCellData alloc] initWithRawData:rawData
                                                                               dataType:kDataType_NormalTitle];
        rawData = @{@"title": @"Favorites",
                    @"action": kAction_Favorites,
                    @"user_screen_name": userScreenName};
        HSUTableCellData *favoritesCellData = [[HSUTableCellData alloc] initWithRawData:rawData
                                                                               dataType:kDataType_NormalTitle];
        rawData = @{@"title": @"Lists",
                    @"action": kAction_Lists,
                    @"user_screen_name": userScreenName};
        HSUTableCellData *listsCellData = [[HSUTableCellData alloc] initWithRawData:rawData
                                                                           dataType:kDataType_NormalTitle];
        [referencesData addObject:followingCellData];
        [referencesData addObject:followersCellData];
        [referencesData addObject:favoritesCellData];
        [referencesData addObject:listsCellData];
        [self.sectionsData addObject:referencesData];
        
        NSMutableArray *draftData = [NSMutableArray arrayWithCapacity:1];
        rawData = @{@"title": @"Drafts",
                    @"action": kAction_Drafts};
        HSUTableCellData *draftsCellData = [[HSUTableCellData alloc] initWithRawData:rawData
                                                                           dataType:kDataType_NormalTitle];
        [draftData addObject:draftsCellData];
        [self.sectionsData addObject:draftData];
    }
    return self;
}

- (void)refresh
{
    [super refresh];
    
    dispatch_async(GCDBackgroundThread, ^{
        NSString *userScreenName = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettings_DBKey][@"screen_name"];
        id result = [TWENGINE getTimelineForUser:userScreenName isID:NO count:3];
        dispatch_sync(GCDMainThread, ^{
            @autoreleasepool {
                if ([result isKindOfClass:[NSArray class]]) {
                    NSArray *tweets = result;
                    for (NSDictionary *tweet in tweets) {
                        HSUTableCellData *statusCellData = [[HSUTableCellData alloc] initWithRawData:tweet dataType:kDataType_Status];
                        [self.data addObject:statusCellData];
                    }
                    if (self.count) {
                        NSDictionary *rawData = @{@"title": @"View More Tweets",
                                                  @"action": kAction_UserTimeline,
                                                  @"user_screen_name": userScreenName};
                        HSUTableCellData *viewMoreCellData =
                            [[HSUTableCellData alloc] initWithRawData:rawData
                                                             dataType:kDataType_NormalTitle];
                        [self.data addObject:viewMoreCellData];
                        [self.delegate dataSource:self didFinishRefreshWithError:nil];
                    }
                }
            }
        });
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSUBaseTableCell *cell = (HSUBaseTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        HSUTableCellData *cellData = [self dataAtIndexPath:indexPath];
        cell = (HSUBaseTableCell *)[tableView dequeueReusableCellWithIdentifier:cellData.dataType];
        [cell setupWithData:cellData];
    }
    return cell;
}

- (HSUTableCellData *)dataAtIndexPath:(NSIndexPath *)indexPath
{
    HSUTableCellData *data = [super dataAtIndexPath:indexPath];
    if (data == nil) {
        data = self.sectionsData[indexPath.section-1][indexPath.row];
    }
    return data;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + self.sectionsData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }
    return [self.sectionsData[section-1] count];
}

@end
