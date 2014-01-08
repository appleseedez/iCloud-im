//
//  ItelBookInterface.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelBook.h"
@class ItelBook;

@protocol ItelBookInterface <NSObject>
//重置
-(void)reset;
//从好友列表中删除联系人
-(void)delUserFromFriendBook:(NSString*)itel;
//添加黑名单
-(void)addUserToBlackBook:(ItelUser*)user;
//从黑名单移除
-(void)removeUserFromBlackBook:(NSString*)itel;
//获得本机通讯录电话
-(NSArray*)getAddressPhoneNumbers;
//找到已有itel用户
-(void)actionWithItelUserInAddressBook:(NSArray*)itelUsers;
//设置备注 好友
-(void)resetUserInFriendBook:(ItelUser*)user;
//设置备注 黑名单
-(void)resetUserInBlackBook:(ItelUser*)user;
//获得通讯录
-(ItelBook*)getAddressBook;
//获得联系人列表
-(ItelBook*)friendBook;
//查询用户在等待确认列表
-(BOOL)checkItelInAddedList:(NSString*)itel;
//添加用户到等待确认列表
-(void)addItelUserIntoAddedList:(NSString *)itel;
//删除用户从等待确认列表
-(void)delItelUserIntoAddedList:(NSString *)itel;
//查询好友列表
-(ItelUser*)userInFriendBook:(NSString*)userItel;
//获得黑名单
-(ItelBook*)getBlackList;
//查询黑名单
-(ItelUser*)userInBlackBook:(NSString*)userItel;
//模糊查询好友
-(NSArray*)searchInfirendBook:(NSString*)search;
//keypath本地查找
-(ItelBook*)searchInFriendBookWithKeyPath:(NSString*)keyPath andSearch:(NSString*)search;
@end
