//
//  ItelAction.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelAction.h"
#import "ItelUserManager.h"
#import "ItelBookManager.h"
#import "ItelNetManager.h"
#import "ItelMessageManager.h"
@implementation ItelAction
+(ItelAction*)action{
    ItelAction *action=[[ItelAction alloc] init];
    action.itelBookActionDelegate=[ItelBookManager defaultManager];
    action.itelUserActionDelegate=[ItelUserManager defaultManager];
    action.itelNetRequestActionDelegate=[ItelNetManager defaultManager];
    action.itelMessageDelegate=[ItelMessageManager defaultManager];
    return action;
}
#pragma mark - 获得机主用户
-(HostItelUser*)getHost{
   return  [self.itelUserActionDelegate hostUser];
}
#pragma mark - 设置机主用户
-(void)setHostItelUser:(HostItelUser*)host{
    [self.itelUserActionDelegate setHost:host];
}
#pragma mark - 获得通讯录
-(void) getAddressBook{
     [self.itelBookActionDelegate getAddressBook];
}
#pragma mark - 刷新itel好友列表

-(void) getItelFriendList:(NSInteger)start{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    
    NSDictionary *parameters = @{@"keyWord":hostUser.userId ,@"start":[NSNumber numberWithInteger:start],@"token":hostUser.token,@"limit":[NSNumber numberWithInteger:2030]};
    [self.itelNetRequestActionDelegate refreshUserList:parameters];
}
-(void) getItelFriendListResponse:(id)data{
   
    NSArray *list = [data objectForKey:@"list"];
    
    for (NSDictionary *dic in (NSArray*)list) {
        ItelUser *user=[ItelUser userWithDictionary:dic];
        
        
        [self.itelBookActionDelegate resetUserInFriendBook:user];
    }
    
    [self NotifyForNormalResponse:@"getItelList" parameters:data];
}
#pragma mark - 刷新黑名单列表
//刷新黑名单列表
-(void) getItelBlackList:(NSInteger)start{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    
    NSDictionary *parameters = @{@"keyWord":hostUser.userId ,@"start":[NSNumber numberWithInteger:start],@"token":hostUser.token,@"limit":[NSNumber numberWithInteger:2030]};
    [self.itelNetRequestActionDelegate refreshBlackList:parameters];
}
-(void) getItelBlackListResponse:(id)data{
    NSArray *list = [data objectForKey:@"list"];
    
    for (NSDictionary *dic in (NSArray*)list) {
        ItelUser *user=[ItelUser userWithDictionary:dic];
        
        
        [self.itelBookActionDelegate resetUserInBlackBook:user];
    }
    
    [self NotifyForNormalResponse:@"getBlackList" parameters:data];
}
#pragma mark - 添加一个好友
/*
  1 获取机主 token  itel userID
  2 发送请求
 */
//查询是否已经添加该联系人
-(BOOL)checkItelAdded:(NSString*)itel{
    return [self.itelBookActionDelegate checkItelInAddedList:itel];
}
-(void)inviteItelUserFriend:(NSString*)itel{
    if (![self checkItelAdded:itel]) {
        
    
     HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"targetItel":itel,@"token":hostUser.token};
    
    [self.itelNetRequestActionDelegate addUser:parameters];
    }
    else {
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"请不要重复发送邀请" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteItelUser" object:nil userInfo:userInfo];
    }
}
//回调
-(void)inviteItelUserFriendResponse:(NSString*)itel{
    [self.itelBookActionDelegate addItelUserIntoAddedList:itel];
    [self NotifyForNormalResponse:@"inviteItelUser" parameters:itel];
}
#pragma mark - 删除好友
/*
 1 获取机主 token  itel userID
 2 发送请求
 */
-(void)delFriendFromItelBook:(NSString*)itel{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"targetItel":itel,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate delUser:parameters];

}
//回调 1通知viewController  2从列表中删除
-(void)delFriendFromItelBookResponse:(NSString*)itel{
    [self.itelBookActionDelegate delItelUserIntoAddedList:itel];
    [self.itelBookActionDelegate delUserFromFriendBook:itel];
    [self NotifyForNormalResponse:@"delItelUser" parameters:nil];
}
#pragma mark - 添加到黑名单
/*
 1 获取机主 token  itel userID
 2 发送请求
 */
-(void) addItelUserBlack:(NSString*)itel{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"targetItel":itel,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate addToBlackList:parameters];
}
-(void) addItelUserBlackResponse:(NSString*)itel{
    
    [self.itelBookActionDelegate addUserToBlackBook:itel];
    [self NotifyForNormalResponse:@"addBlack" parameters:nil];

}

#pragma mark - 从黑名单移除
//
-(void) delFriendFromBlack:(NSString*)itel{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"targetItel":itel,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate removeFromBlackList:parameters];
}
-(void) delFriendFromBlackResponse:(NSString*)itel{
    
    [self.itelBookActionDelegate removeUserFromBlackBook:itel];
    [self NotifyForNormalResponse:@"removeBlack" parameters:nil];
}
#pragma mark - 获得黑名单
-(ItelBook*) blackList{
    return [self.itelBookActionDelegate getBlackList];
}
#pragma  mark - 匹配通讯录好友
/*匹配通讯录中得联系人接口
 1 获得本机所有联系人电话
 2 网络请求
 */
-(void) checkAddressBookMatchingItel{
    
    dispatch_queue_t getPhones=dispatch_queue_create("getPhones", NULL);
    dispatch_async(getPhones, ^{
        NSArray *phones =  [self.itelBookActionDelegate getAddressPhoneNumbers];
        
        [self.itelNetRequestActionDelegate checkAddressBookForItelUser:phones];
    });
    
    
}
/*
  回调：
 
 */
-(void) checkAddressBookMatchingResponse:(NSArray*)matchingItelUsers{
    
    [self.itelBookActionDelegate actionWithItelUserInAddressBook:matchingItelUsers];
    [self NotifyForNormalResponse:@"checkAddress" parameters:nil];
}
#pragma mark - 编辑好友备注
/*
  1 发送请求 
  2 请求返回成功 设置新的备注
 */
-(void) editUser:(NSString*)itel alias:(NSString*)alias{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"targetItel":itel,@"token":hostUser.token,@"alias":alias};
    
    [self.itelNetRequestActionDelegate editUserRemark:itel user:parameters];
}

-(void)editUserAliasResponse:(NSDictionary*)user{
    ItelUser *u=[ItelUser userWithDictionary:user];
 
        [self.itelBookActionDelegate resetUserInFriendBook:u];

    if (u.isBlack) {
        [self.itelBookActionDelegate resetUserInBlackBook:u];
    }
    [self NotifyForNormalResponse:@"resetAlias" parameters:u];
}
#pragma mark - 查找陌生人
/*
  1 得到查找关键词 发网络请求
 
 */
-(void) searchStranger:(NSString*)searchMessage newSearch:(BOOL)newSearch{
    [self.itelNetRequestActionDelegate searchUser:searchMessage isNewSearch:newSearch];
    
}
//回调
-(void) searchStrangerResponse:(id)response isEnd:(BOOL)isEnd{
    [self NotifyForNormalResponse:@"searchStranger" parameters:response];
}
#pragma mark - 上传图片
-(void)uploadImage:(UIImage*)image{
    NSData *imgData=UIImagePNGRepresentation(image);
    //NSData *imgData=UIImageJPEGRepresentation(image, 1);
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"hostItel":hostUser.itelNum,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate uploadImage:imgData parameters:parameters];
}
//回调
-(void)uploadImageResponse:(NSDictionary*)response{
    
   HostItelUser *hostUser = [self.itelUserActionDelegate hostUser];
    NSString *imageUrl=[response objectForKey:@"data"];
    hostUser.imageurl=imageUrl;
    [self NotifyForNormalResponse:@"modifyHost" parameters:response];
    
}
#pragma  mark - 修改个人资料
-(void)modifyPersonal:(NSString*)key forValue:(NSString*)value{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itel":hostUser.itelNum,@"token":hostUser.token,@"key":key,@"value":value};
    [self.itelNetRequestActionDelegate modifyPersonal:parameters];
}
-(void)modifyPersonalResponse:(NSDictionary*)data{
    [self.itelUserActionDelegate modifyPersonal:data];
    [self  NotifyForNormalResponse:@"modifyHost" parameters:data];
}
#pragma mark - 验证手机号码是否可用
-(void)checkPhoneNumber:(NSString*)phone{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itelCode":hostUser.itelNum,@"token":hostUser.token,@"phone":phone,};
    [self.itelNetRequestActionDelegate checkNewTelNum:parameters];
}
-(void)checkPhoneNumberResponse:(NSDictionary*)response{
    [self NotifyForNormalResponse:@"modifyPhone" parameters:nil];
}
#pragma mark - 修改手机-发送短信验证码
-(void)phoneCheckCode:(NSString*)checkCode phone:(NSString*)phone{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
   NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itelCode":hostUser.itelNum,@"token":hostUser.token,@"captcha":checkCode,@"phone":phone};
    [self.itelNetRequestActionDelegate modifyPhoneNumCheckCode:parameters];
}
-(void)phoneCheckCodeResponse:(id)response{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    hostUser.telNum=(NSString*)response;
    [self NotifyForNormalResponse:@"phoneCheckCode" parameters:nil];
}

#pragma mark - 重新发送短信
-(void)resendMassage:(NSString*)phone{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itelCode":hostUser.itelNum,@"token":hostUser.token,@"phone":phone,};
    [self.itelNetRequestActionDelegate resendPhoneMessage:parameters];
}
-(void)resendMassageResponse:(NSDictionary*)response{
    NSString *msg=[response objectForKey:@"msg"];
    if (msg) {
        [self NotifyForNormalResponse:@"resendMes" parameters:msg];
    }
    else{
    [self NotifyForNormalResponse:@"resendMes" parameters:nil];
    }
}
#pragma mark - 修改密保-查询密保
-(void)checkOutProtection{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId };
    [self.itelNetRequestActionDelegate getPasswordProtection:parameters];
}
-(void)checkOutProtectionResponse:(NSDictionary*)response{
    [self NotifyForNormalResponse:@"passwordProtection" parameters:response];
}
#pragma mark - 修改用户密码
-(void)modifyUserPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"token":hostUser.token,@"oldPassword":oldPassword,@"newPassword":newPassword,};
    [self.itelNetRequestActionDelegate changePassword:parameters];
}
-(void)modifyUserPasswordResponse:(NSDictionary*)response{
    
    [self NotifyForNormalResponse:@"changePassword" parameters:response];
   
}
#pragma mark - 回答密保问题
-(void)securetyAnswserQuestion:(NSString*)question answser:(NSString*)answer{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"token":hostUser.token,@"question":question,@"answer":answer,};
    [self.itelNetRequestActionDelegate securetyAnsewerQuestion:parameters];
}
-(void)securetyAnswserQuestionResponse:(NSDictionary*)response{
    [self NotifyForNormalResponse:@"answerQuestion" parameters:response];
}
#pragma mark - 修改密保设置
-(void)modifySecuretyProduction:(NSDictionary*)parameters{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    parameters =[parameters mutableCopy];
    [parameters setValue:hostUser.userId forKey:@"userId"];
    [parameters setValue:hostUser.token forKey:@"token"];
    [self.itelNetRequestActionDelegate sendSecuretyProduction:parameters];
}
-(void)modifySecuretyProductionResponse:(NSDictionary*)response{
    [self NotifyForNormalResponse:@"modifySecurety" parameters:response];
}


#pragma mark - 查询新消息
-(void)searchForNewMessage{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"itel":hostUser.itelNum ,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate searchNewMessage:parameters];
}
-(void)searchForNewMessageResponse:(NSDictionary*)data{
    [self NotifyForNormalResponse:@"searchForNewMessage" parameters:data];
}
#pragma mark - 刷新新消息
-(void)getNewMessage{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"itel":hostUser.itelNum ,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate refreshForNewMessage:parameters];
}
-(void)getNewMessageResponse:(NSDictionary*)data{
    NSArray *arr=[data objectForKey:@"data"];
    [self.itelMessageDelegate addNewMessages:arr];
    
    [self NotifyForNormalResponse:@"getNewMessage" parameters:data];
}
#pragma mark - 获得本地消息列表
-(NSArray*)getMessageList{
   return  [self.itelMessageDelegate getSystemMessages];
}
-(ItelBook*) getFriendBook{
    return [self.itelBookActionDelegate friendBook];
}
#pragma mark - 处理好友邀请
-(void)acceptFriendIvication:(NSString*)targetItel status:(NSString*)status{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
   NSDictionary *parameters = @{@"hostItel":hostUser.itelNum ,@"userId":hostUser.userId,@"targetItel":targetItel,@"status":status};
    [self.itelNetRequestActionDelegate acceptIvitation:parameters];
}
-(void)acceptFriendIvicationResponse:(NSDictionary*)data{
    [self NotifyForNormalResponse:@"acceptFriends" parameters:data];
}
//查找好友列表
-(ItelUser*)userInFriendBook:(NSString*)itel{
    return [self.itelBookActionDelegate userInFriendBook:itel];
}
//查找黑名单
-(ItelUser*)userInBlackBook:(NSString*)itel{
    return [self.itelBookActionDelegate userInBlackBook:itel];
}
//模糊查找好友(用过itel)
-(NSArray*)searchInFirendBook:(NSString*)search{
   return  [self.itelBookActionDelegate searchInfirendBook:search];
}
-(ItelBook*)searchInFriendBookWithKeyPath:(NSString*)keyPath andSearch:(NSString*)search{
    ItelBook *result=[self.itelBookActionDelegate searchInFriendBookWithKeyPath:keyPath andSearch:search];
    return result;
}
#pragma mark - 响应正常返回的通知(异常由netManager直接通知)

-(void) NotifyForNormalResponse:(NSString*)name parameters:(id)parameters{
    NSDictionary *userInfo=@{@"isNormal": @"1",@"reason":@"1" };
    
    [[NSNotificationCenter defaultCenter]postNotificationName:name object:parameters userInfo:userInfo];
}
@end
