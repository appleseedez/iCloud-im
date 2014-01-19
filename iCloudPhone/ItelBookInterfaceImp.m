//
//  ItelBookInterfaceImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/8/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelBookInterfaceImp.h"
#import "HostItelUser+set.h"
#import "ItelUser+CRUD.h"
#import "IMCoreDataManager.h"
#import "AddressBook.h"
#import "ItelAction.h"
#import "ItelBook.h"
#import "NSCAppDelegate.h"
@interface ItelBookInterfaceImp()

@end


@implementation ItelBookInterfaceImp
//重置
-(void)reset{
    // 切换HostItelUser其中的friendBook 和 blackBook 就会重置 所以目前的reset接口就不需要有动作了
}
//从好友列表中删除联系人
-(void)delUserFromFriendBook:(NSString*)itel{
    ItelUser* matchedUser;
    HostItelUser* hostUser = [[ItelAction action] getHost];
    NSPredicate* findByItelNum = [NSPredicate predicateWithFormat:@"itelNum = %@ AND isFriend = %@",itel,[NSNumber numberWithBool:YES]];
    NSArray* matched = [[hostUser.users filteredSetUsingPredicate:findByItelNum] allObjects];
    if ([matched count]) {
        matchedUser = matched[0];
        [matchedUser.managedObjectContext performBlock:^{
            matchedUser.isFriend = [NSNumber numberWithBool:NO];
            [[IMCoreDataManager defaulManager] saveContext:matchedUser.managedObjectContext];
        }];

    }
}
//添加黑名单
-(void)addUserToBlackBook:(ItelUser*)user{
    [user.managedObjectContext performBlock:^{
        user.isBlack = [NSNumber numberWithBool:YES];
        [[IMCoreDataManager defaulManager] saveContext:user.managedObjectContext];
    }];

}
//从黑名单移除
-(void)removeUserFromBlackBook:(NSString*)itel{
    ItelUser* matchedUser;
    HostItelUser* hostUser = [[ItelAction action] getHost];
    NSPredicate* findByItelNum = [NSPredicate predicateWithFormat:@"itelNum = %@ AND isBlack = %@",itel,[NSNumber numberWithBool:YES]];
    NSArray* matched = [[hostUser.users filteredSetUsingPredicate:findByItelNum] allObjects];
    if ([matched count]) {
        matchedUser = matched[0];
        [matchedUser.managedObjectContext performBlock:^{
            matchedUser.isBlack = [NSNumber numberWithBool:NO];
            [[IMCoreDataManager defaulManager] saveContext:matchedUser.managedObjectContext];
        }];

    }
}
//获得本机通讯录电话
-(NSArray*)getAddressPhoneNumbers{
    return [self.phoneBook getAllKeys];
}
//找到已有itel用户
-(void)actionWithItelUserInAddressBook:(NSArray*)itelUsers{
    NSManagedObjectContext* currentContext = [IMCoreDataManager defaulManager].managedObjectContext;
    [currentContext performBlock:^{
        for (NSDictionary* dic in itelUsers) {
            ItelUser* user = [ItelUser userWithDictionary:dic inContext:currentContext];
            [self.phoneBook setValue:user forKeyPath:[NSString stringWithFormat:@"users.%@.itelUser",user.telNum]];
        }
        [[IMCoreDataManager defaulManager] saveContext:currentContext];
    }];
 
}
//刷新好友列表,把好友信息刷新上去
-(void)resetUserInFriendBook:(ItelUser*)user{
    user.isFriend = [NSNumber numberWithBool:YES];
}
//设置备注 黑名单
-(void)resetUserInBlackBook:(ItelUser*)user{
    user.isBlack = [NSNumber numberWithBool:YES];
}


- (AddressBook*) phoneBook{
    
   return  ((NSCAppDelegate*)[UIApplication sharedApplication].delegate).phoneBook;

    
}
//获得通讯录
-(ItelBook*)getAddressBook{
    return [self phoneBook];
//    if (_phoneBook==nil) {
//        [self phoneBook];
//    }
//    else
 
}
//获得联系人列表
-(ItelBook*)friendBook{
    HostItelUser* hostUser =  [[ItelAction action] getHost];
    ItelBook* itelBook = [ItelBook new];
//    
//    for (ItelUser* u in hostUser.users) {
//        NSLog(@"当前用户关联的:%@",u.itelNum);
//    }
    for (ItelUser* user in hostUser.users) {
        if ([user.isFriend boolValue]) {
            [itelBook addUser:user forKey:user.itelNum];
        }
    }
    return itelBook;
}
//查询用户在等待确认列表
-(BOOL)checkItelInAddedList:(NSString*)itel{
    return NO;
}
//添加用户到等待确认列表
-(void)addItelUserIntoAddedList:(NSString *)itel{
    //
}
//删除用户从等待确认列表
-(void)delItelUserIntoAddedList:(NSString *)itel{
    //
}
//查询好友列表
-(ItelUser*)userInFriendBook:(NSString*)userItel{
    HostItelUser* hostUser =  [[ItelAction action] getHost];
    ItelUser* matchedUser;
    NSPredicate* findByItelNum = [NSPredicate predicateWithFormat:@"itelNum = %@",userItel];
    NSArray* match = [[hostUser.users filteredSetUsingPredicate:findByItelNum] allObjects];
    if ([match count]) {
        matchedUser = match[0];
    }
    if ([matchedUser.isFriend boolValue]) {
        return matchedUser;
    }
    return nil;
}
//获得黑名单
-(ItelBook*)getBlackList{
    HostItelUser* hostUser =  [[ItelAction action] getHost];
    ItelBook* itelBook = [ItelBook new];
    for (ItelUser* user in hostUser.users) {
        if ([user.isBlack boolValue]) {
            [itelBook addUser:user forKey:user.itelNum];
        }
    }
    return itelBook;
}
//查询黑名单
-(ItelUser*)userInBlackBook:(NSString*)userItel{
    HostItelUser* hostUser =  [[ItelAction action] getHost];
    ItelUser* matchedUser;
    NSPredicate* findByItelNum = [NSPredicate predicateWithFormat:@"itelNum = %@",userItel];
    NSArray* match = [[hostUser.users filteredSetUsingPredicate:findByItelNum] allObjects];
    if ([match count]) {
        matchedUser = match[0];
    }
    if ([matchedUser.isBlack boolValue]) {
        return matchedUser;
    }
    return nil;
}
//模糊查询好友
-(NSArray*)searchInfirendBook:(NSString*)search{
    ItelBook* matched =  [self searchInFriendBookWithKeyPath:@"itelNum" andSearch:search];
    NSMutableArray* matchedUsers = [NSMutableArray new];
    NSArray* matchedAllKeys = [matched getAllKeys];
    for (NSString* key in matchedAllKeys) {
        [matchedUsers addObject:[matched userForKey:key]];
    }
    return  matchedUsers;
    
}
//keypath本地查找
-(ItelBook*)searchInFriendBookWithKeyPath:(NSString*)keyPath andSearch:(NSString*)search{
   return [[self friendBook] searchInKeypath:keyPath andSearch:search];
    
}
@end
