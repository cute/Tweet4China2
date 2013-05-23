//
//  HSUMessagesDataSource.m
//  Tweet4China
//
//  Created by Jason Hsu on 5/21/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "HSUConversationsDataSource.h"

@implementation HSUConversationsDataSource

- (void)refresh
{
    [super refresh];
    
    dispatch_async(GCDBackgroundThread, ^{
        NSString *sinceId = nil;
        for (HSUTableCellData *cellData in self.data) {
            NSDictionary *conversation = cellData.rawData;
            NSArray *messages = conversation[@"messages"];
            if (messages.count) {
                NSDictionary *message = messages[0];
                sinceId = message[@"id_str"];
                break;
            }
        }
        id rMsgs = [TWENGINE getDirectMessagesSinceID:sinceId];
        id sMsgs = [TWENGINE getSentDirectMessagesSinceID:sinceId];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_sync(GCDMainThread, ^{
            @autoreleasepool {
                __strong __typeof(&*weakSelf)strongSelf = weakSelf;
                if ([TWENGINE dealWithError:rMsgs errTitle:@"Load Messages failed"] &&
                    [TWENGINE dealWithError:sMsgs errTitle:@"Load Messages failed"]) {
                    
                    // merge received messages & sent messages
                    NSArray *messages = [[NSArray arrayWithArray:rMsgs] arrayByAddingObjectsFromArray:sMsgs];
                    
                    // reorgnize messages as dict, friend_screen_name as key, refered messages as value
                    NSMutableDictionary *conversations = [[NSMutableDictionary alloc] init];
                    NSMutableArray *orderedFriendScreenNames = [NSMutableArray array];
                    for (NSDictionary *message in messages) {
                        NSString *sender_sn = message[@"sender_screen_name"];
                        NSString *recipient_sn = message[@"recipient_screen_name"];
                        
                        NSString *fsn = [MyScreenName isEqualToString:sender_sn] ? recipient_sn : sender_sn;
                        NSMutableArray *conversation = conversations[fsn];
                        if (!conversation) {
                            conversation = [NSMutableArray array];
                            conversations[fsn] = conversation;
                            [orderedFriendScreenNames addObject:fsn];
                        }
                        [conversation addObject:message];
                    }
                    
                    // create cell data, rawData is dict with keys: user, messages, created_at
                    for (NSString *fsn in orderedFriendScreenNames) {
                        NSMutableDictionary *conversation = [NSMutableDictionary dictionary];
                        NSArray *messages = conversations[fsn];
                        NSDictionary *latestMessage = messages[0];
                        NSString *sender_sn = latestMessage[@"sender_screen_name"];
                        
                        conversation[@"user"] = [fsn isEqualToString:sender_sn] ? latestMessage[@"sender"] : latestMessage[@"recipient"];
                        conversation[@"messages"] = messages;
                        conversation[@"created_at"] = latestMessage[@"created_at"];
                        
                        HSUTableCellData *cellData = [[HSUTableCellData alloc] initWithRawData:conversation
                                                                                      dataType:kDataType_Conversation];
                        [self.data addObject:cellData];
                    }
                    
                    [strongSelf saveCache];
                    [strongSelf.delegate preprocessDataSourceForRender:self];
                    [strongSelf.delegate dataSource:strongSelf didFinishRefreshWithError:nil];
                    strongSelf.loadingCount --;
                }
            }
        });
    });
}

@end
