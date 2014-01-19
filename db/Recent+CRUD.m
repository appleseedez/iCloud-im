//
//  Recent+CRUD.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/4/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "Recent+CRUD.h"
#import "IMCoreDataManager.h"
#import "ConstantHeader.h"
@implementation Recent (CRUD)
- (void)delete{
    [[IMCoreDataManager defaulManager] deletObject:self inContext:self.managedObjectContext];
}
+ (void) deleteAllWithAccount:(NSString*) accountNumber {
    NSManagedObjectContext* currentContext =[[IMCoreDataManager defaulManager] managedObjectContext];
    if (currentContext) {
        [currentContext performBlock:^{
            NSError* error;
            NSFetchRequest* deleteAll = [NSFetchRequest fetchRequestWithEntityName:TABLE_NAME_RECENT];
            deleteAll.sortDescriptors = @[];
            deleteAll.predicate = [NSPredicate predicateWithFormat:@"hostUserNumber = %@",accountNumber];
            NSArray* allRecents = [currentContext executeFetchRequest:deleteAll error:&error];
            for (Recent* i in allRecents) {
                [currentContext deleteObject:i];
            }
            [currentContext save:&error];
        }];

    }
}
//插入新数据到数据库.
+ (instancetype)recentWithCallInfo:(NSDictionary *)info inContext:(NSManagedObjectContext *)context{
    //简单检查下传人的info是否足够.不足则不会操作数据
    if ([info.allKeys count] <7) {
        [NSException exceptionWithName:@"创建recent数据失败." reason:@"info is not enough to create a recent object " userInfo:nil];
        return nil;
    }
    Recent* aRecent = [NSEntityDescription insertNewObjectForEntityForName:@"Recent" inManagedObjectContext:context];
    aRecent.peerAvatar = [info valueForKey:kPeerAvatar];
    aRecent.createDate = [info valueForKey:kCreateDate];
    aRecent.peerNick = [info valueForKey:kPeerNick];
    aRecent.peerRealName = [info valueForKey:kPeerRealName];
    aRecent.peerNumber = [info valueForKey:kPeerNumber];
    aRecent.status = [info valueForKey:kStatus];
    aRecent.duration = [info valueForKey:kDuration];
    aRecent.hostUserNumber = [info valueForKey:kHostUserNumber];

    return aRecent;

}
@end
