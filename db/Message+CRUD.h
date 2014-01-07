//
//  Message+CRUD.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Message.h"

@interface Message (CRUD)
+(instancetype)messageWithDic:(NSDictionary*)data inContext:(NSManagedObjectContext*) context;
+(NSArray*) allMessagesInContext:(NSManagedObjectContext*) context;
@end
