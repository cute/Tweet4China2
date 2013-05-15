//
//  HSUDraftsDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/15/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUDraftsDataSource.h"
#import "HSUDraftManager.h"

@implementation HSUDraftsDataSource

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *drafts = [[HSUDraftManager shared] draftsSortedByUpdateTime];
        for (NSDictionary *draft in drafts) {
            HSUTableCellData *cellData = [[HSUTableCellData alloc] initWithRawData:draft dataType:kDataType_Draft];
            [self.data addObject:cellData];
        }
    }
    return self;
}

@end
