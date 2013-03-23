//
//  FHSTwitterEngine+Addition.h
//  Tweet4China
//
//  Created by Jason Hsu on 3/23/13.
//  Copyright (c) 2013 Jason Hsu <support@tuoxie.me>. All rights reserved.
//

#import "FHSTwitterEngine.h"

@interface FHSTwitterEngine (Addition)

- (id)getHomeTimelineMaxId:(NSString *)maxId count:(int)count;

@end
