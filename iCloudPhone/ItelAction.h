//
//  ItelAction.h
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//  用来封装对itel电话本操作的动作 用不用另说

#import <Foundation/Foundation.h>
#import "HostItelUser.h"
@class ItelBook;
#pragma  mark - 联系人列表操作协议
@protocol ItelBookActionDelegate <NSObject>
//从好友列表中删除联系人
-(void)delUserFromFriendBook:(NSString*)itel;
//添加黑名单
-(void)addUserToBlackBook:(NSString*)itel;
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
-(void)getAddressBook;
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

#pragma  mark - 用户操作协议
@protocol ItelUserActionDelegate <NSObject>
//本机用户
-(HostItelUser*)hostUser;
//设置本机用户
-(void)setHost:(HostItelUser*)host;

-(void)modifyPersonal:(NSDictionary*)data;
-(void)callUser:(ItelUser*)user;

@end


#pragma mark - 网络请求协议

@protocol ItelNetRequestActionDelegate <NSObject>

//匹配通讯录中联系人
-(void)checkAddressBookForItelUser:(NSArray*)phones;
//查找陌生人
-(void)searchUser:(NSString*)search isNewSearch:(BOOL)isNewSearch;
//添加联系人
-(void)addUser:(NSDictionary*)parameters;
//删除联系人
-(void)delUser:(NSDictionary*)parameters;

//添加联系人到黑名单
-(void)addToBlackList:(NSDictionary*)parameters;
//从黑名单中移除
-(void)removeFromBlackList:(NSDictionary*)parameters;
//编辑用户备注
-(void)editUserRemark:(NSString*)newRemark user:(NSDictionary*)parameters;
//刷新好友列表
-(void)refreshUserList:(NSDictionary*)parameters;
//刷新黑名单列表
-(void)refreshBlackList:(NSDictionary*)parameters;
//上传图片
-(void)uploadImage:(NSData*)imageData parameters:(NSDictionary*)parameters;
//修改个人资料
-(void) modifyPersonal:(NSDictionary*)parameters;
//修改手机-验证新号码
-(void) checkNewTelNum:(NSDictionary*)parameters;
//修改手机-发送短信验证码
-(void) modifyPhoneNumCheckCode:(NSDictionary*)parameters;
//修改手机-重新发送短信
-(void) resendPhoneMessage:(NSDictionary*)parameters;
//修改用户密码
-(void)changePassword:(NSDictionary*)parameters;
//修改密保-验证密保
-(void)getPasswordProtection:(NSDictionary*)parameters;
@end
@interface ItelAction : NSObject
@property (nonatomic,weak) id <ItelBookActionDelegate> itelBookActionDelegate;
@property (nonatomic,weak) id <ItelUserActionDelegate> itelUserActionDelegate;
@property (nonatomic,weak) id <ItelNetRequestActionDelegate>itelNetRequestActionDelegate;
+(ItelAction*)action;
//获得机主用户
-(HostItelUser*)getHost;
//设置机主用户
-(void)setHostItelUser:(HostItelUser*)host;

#pragma  mark - 网络请求
//匹配通讯录好友
-(void) checkAddressBookMatchingItel;
-(void) checkAddressBookMatchingResponse:(NSArray*)matchingItelUsers;
//查找陌生人
-(void) searchStranger:(NSString*)searchMessage newSearch:(BOOL)newSearch;
-(void) searchStrangerResponse:(id)response isEnd:(BOOL)isEnd;
//添加好友
-(void) inviteItelUserFriend:(NSString*)itel;
-(void) inviteItelUserFriendResponse:(NSString*)itel;
//删除好友
-(void) delFriendFromItelBook:(NSString*)itel;
-(void) delFriendFromItelBookResponse:(NSString*)itel;
//添加到黑名单
-(void) addItelUserBlack:(NSString*)itel;
-(void) addItelUserBlackResponse:(NSString*)itel;
//从黑名单移除
-(void) delFriendFromBlack:(NSString*)itel;
-(void) delFriendFromBlackResponse:(NSString*)itel;
//编辑好友备注
-(void) editUser:(NSString*)itel alias:(NSString*)alias;
-(void) editUserAliasResponse:(NSDictionary*)user;
//刷新itel好友列表
-(void) getItelFriendList:(NSInteger)start;
-(void) getItelFriendListResponse:(id)data;
//刷新黑名单列表
-(void) getItelBlackList:(NSInteger)start;
-(void) getItelBlackListResponse:(id)data;
//获得黑名单
-(ItelBook*) blackList;
//获得通讯录
-(void) getAddressBook;
//获得itel好友列表
-(ItelBook*) getFriendBook;
//上传图片
-(void)uploadImage:(UIImage*)image;
-(void)uploadImageResponse:(NSDictionary*)response;
//查询是否已经添加该联系人
-(BOOL)checkItelAdded:(NSString*)itel;
//修改个人资料
-(void)modifyPersonal:(NSString*)key forValue:(NSString*)value;
-(void)modifyPersonalResponse:(NSDictionary*)data;
//修改手机-验证手机号码是否可用
-(void)checkPhoneNumber:(NSString*)phone;
-(void)checkPhoneNumberResponse:(NSDictionary*)response;
//修改手机-发送短信验证码
-(void)phoneCheckCode:(NSString*)checkCode phone:(NSString*)phone;
-(void)phoneCheckCodeResponse:(id)response;
//重新发送短信
-(void)resendMassage:(NSString*)phone;
-(void)resendMassageResponse:(NSDictionary*)response;
//修改用户密码
-(void)modifyUserPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;
-(void)modifyUserPasswordResponse:(NSDictionary*)response;
//修改密保-查询密保
-(void)checkOutProtection;
#pragma mark - 查找本机用户接口
//精确查找好友列表
-(ItelUser*)userInFriendBook:(NSString*)itel;
//警觉查找黑名单
-(ItelUser*)userInBlackBook:(NSString*)itel;
//模糊查找好友
-(NSArray*)searchInFirendBook:(NSString*)search;
/*keypath 查找好友列表 keypath为需要匹配得iteluser的属性 如字符串的形式如 昵称 @“nickName”  电话 @“telNum” 备注 @“remarkName” 返回itelbook 如需要多种搜索 多次调用用appendingByItelBook拼接返回的itelBook*/
-(ItelBook*)searchInFriendBookWithKeyPath:(NSString*)keyPath andSearch:(NSString*)search;

@end
