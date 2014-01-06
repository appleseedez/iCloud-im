//
//  Recent+CRUD.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/4/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Recent.h"

@interface Recent (CRUD)
+ (instancetype) recentWithCallInfo:(NSDictionary*) info inContext:(NSManagedObjectContext*) context;
- (void) delete;
+ (void) deleteAll:(NSString*) accountNumber;
@end
