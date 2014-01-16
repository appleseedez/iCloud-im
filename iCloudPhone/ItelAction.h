//
//  ItelAction.h
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//  用来封装对itel电话本操作的动作 用不用另说

#import <Foundation/Foundation.h>
#import "HostItelUser+set.h"
#import "ItelUser.h"
#import "ItelMessageInterface.h"
#import "ItelBookInterface.h"
#import "ItelUserInterface.h"
#import "ItelNetInterface.h"
@class ItelBook;
@class AddressBook;
@interface ItelAction : NSObject
@property (nonatomic) id <ItelBookInterface> itelBookActionDelegate;
@property (nonatomic) id <ItelUserInterface> itelUserActionDelegate;
@property (nonatomic) id <ItelNetInterface>itelNetRequestActionDelegate;
@property (nonatomic,weak) id <ItelMessageInterface> itelMessageDelegate;
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
-(void) addItelUserBlackResponse:(NSDictionary*)userDic;
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
//查询黑名单
- (ItelUser*) queryBlackList:(NSString*) itelNum;
//获得通讯录
-(AddressBook*) getAddressBook;
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
-(void)checkOutProtectionResponse:(NSDictionary*)response;
//回答密保问题
-(void)securetyAnswserQuestion:(NSString*)question answser:(NSString*)answer;
-(void)securetyAnswserQuestionResponse:(NSDictionary*)response;
//修改密保设置
-(void)modifySecuretyProduction:(NSDictionary*)parameters;
-(void)modifySecuretyProductionResponse:(NSDictionary*)response;
#pragma mark - 查找本机用户接口
//精确查找好友列表
-(ItelUser*)userInFriendBook:(NSString*)itel;
//警觉查找黑名单
-(ItelUser*)userInBlackBook:(NSString*)itel;
//模糊查找好友
-(NSArray*)searchInFirendBook:(NSString*)search;
/*keypath 查找好友列表 keypath为需要匹配得iteluser的属性 如字符串的形式如 昵称 @“nickName”  电话 @“telNum” 备注 @“remarkName” 返回itelbook 如需要多种搜索 多次调用用appendingByItelBook拼接返回的itelBook*/
-(ItelBook*)searchInFriendBookWithKeyPath:(NSString*)keyPath andSearch:(NSString*)search;
#pragma mark - 消息接口
//查询新消息
-(void)searchForNewMessage;
-(void)searchForNewMessageResponse:(NSDictionary*)data;
//刷新新消息
-(void)getNewMessage;
-(void)getNewMessageResponse:(NSDictionary*)data;
//获得本地消息列表
-(NSArray*)getMessageList;
//处理好友邀请
-(void)acceptFriendIvication:(NSString*)targetItel status:(NSString*)status;
-(void)acceptFriendIvicationResponse:(NSDictionary*)data;
//重置联系人列表
-(void)resetContact;
//退出登录
-(void)logout;
-(void)logoutResponse;
@end
