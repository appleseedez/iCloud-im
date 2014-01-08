//
//  Message+CRUD.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Message+CRUD.h"
#import "ItelUser+CRUD.h"
@implementation Message (CRUD)
+(instancetype)messageWithDic:(NSDictionary*)data inContext:(NSManagedObjectContext*) context{
    
    Message* mes = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    mes.date=[data objectForKey:@"date"];
    mes.body=[data objectForKey:@"msg"];
    mes.title=@"请求加你好友";
    ItelUser* aUser = [ItelUser userWithDictionary:[data objectForKey:@"contact"]];
    mes.sender=aUser;
    mes.isRead = [NSNumber numberWithBool:NO];
    return mes;
}

+(NSArray*) allMessagesInContext:(NSManagedObjectContext*) context{
    NSError* error = nil;
    NSFetchRequest* getAllMessages = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    //TODO: 按时间逆序
    getAllMessages.sortDescriptors = @[];
    return [context executeFetchRequest:getAllMessages error:&error];
}
@end
