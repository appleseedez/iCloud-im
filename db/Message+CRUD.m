//
//  Message+CRUD.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Message+CRUD.h"
#import "ItelUser+CRUD.h"
#import "ItelAction.h"
#import "IMCoreDataManager.h"
@implementation Message (CRUD)
+(instancetype)messageWithDic:(NSDictionary*)data inContext:(NSManagedObjectContext*) context{
    Message* mes;
    if (context) {
        mes = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        mes.date=[data objectForKey:@"date"];
        mes.body=[data objectForKey:@"msg"];
        mes.title=@"请求加你好友";
        ItelUser* aUser = [ItelUser userWithDictionary:[data objectForKey:@"contact"] inContext:context];
        HostItelUser* hostUser = [[ItelAction action] getHost];
        [hostUser.systemMessages setByAddingObject:mes];
        mes.sender=aUser;
        mes.receiver = hostUser;
        mes.isRead = [NSNumber numberWithBool:NO];
    }

    return mes;
}

+(NSArray*) allMessagesInContext:(NSManagedObjectContext*) context{
    NSError* error = nil;
    NSFetchRequest* getAllMessages = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
    //TODO: 按时间逆序
    getAllMessages.sortDescriptors = @[];
    getAllMessages.predicate = [NSPredicate predicateWithFormat:@"receiver.itelNum = %@",[[ItelAction action] getHost].itelNum];
    return [context executeFetchRequest:getAllMessages error:&error];
}
@end
