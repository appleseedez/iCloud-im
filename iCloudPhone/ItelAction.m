//
//  ItelAction.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelAction.h"
#import "IMCoreDataManager.h"
#import "ItelUser+CRUD.h"
#import "ItelUserInterfaceImp.h"
#import "ItelNetInterfaceImp.h"
#import "ItelMessageInterfaceImp.h"
#import "ItelBookInterfaceImp.h"
#import "AddressBook.h"
#import "ItelIntentImp.h"
#import "NSCAppDelegate.h"
@interface ItelMessageInterfaceImp()
+ (instancetype) defaultMessageInterface;
@end
@implementation ItelAction
+(ItelAction*)action{
    ItelAction *action=[[ItelAction alloc] init];
    action.itelBookActionDelegate=[ItelBookInterfaceImp new];//[ItelBookManager defaultManager];
    action.itelUserActionDelegate=[ItelUserInterfaceImp new];
    action.itelNetRequestActionDelegate=[ItelNetInterfaceImp new];
    action.itelMessageDelegate=[ItelMessageInterfaceImp defaultMessageInterface];
    return action;
}
#pragma mark - 重置联系人列表
-(void)resetContact{
    [self.itelBookActionDelegate reset];
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
-(AddressBook*) getAddressBook{
    return  (AddressBook*)[self.itelBookActionDelegate getAddressBook];
}
#pragma mark - 刷新itel好友列表

-(void) getItelFriendList:(NSInteger)start{
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSLog(@"%@",hostUser.userId);
    NSDictionary *parameters = @{@"keyWord":hostUser.userId ,@"start":[NSNumber numberWithInteger:start],@"token":hostUser.token,@"limit":[NSNumber numberWithInteger:2030]};
    [self.itelNetRequestActionDelegate refreshUserList:parameters];
}
-(void) getItelFriendListResponse:(id)data{
    
    NSArray *list = [data objectForKey:@"list"];
    
    NSManagedObjectContext* currentContext = [IMCoreDataManager defaulManager].managedObjectContext;
    for (NSDictionary *dic in (NSArray*)list) {
        ItelUser *user=[ItelUser userWithDictionary:dic inContext:currentContext];
        [self.itelBookActionDelegate resetUserInFriendBook:user];
    }
    [[IMCoreDataManager defaulManager] saveContext:currentContext];
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
    NSManagedObjectContext* currentContext =[IMCoreDataManager defaulManager].managedObjectContext;
    
    for (NSDictionary *dic in (NSArray*)list) {
        ItelUser *user=[ItelUser userWithDictionary:dic inContext:currentContext];
        [self.itelBookActionDelegate resetUserInBlackBook:user];
    }
    [[IMCoreDataManager defaulManager] saveContext:currentContext];
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
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    if ([itel isEqualToString:hostUser.itelNum]) {
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"请不要添加自己" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteItelUser" object:nil userInfo:userInfo];
        return;
    }
    
    if (![self checkItelAdded:itel]) {
        
        
        
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
    
    id <ItelIntent> intent=[ItelIntentImp newIntent:intentTypeMessage];
    intent.userInfo=@{@"title":@"发送成功",@"body":@"请等待对方确认"};
    [self NotifyForNormalResponse:ADD_FIRIEND_NOTIFICATION intent:intent];
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
    id <ItelIntent> intent=[ItelIntentImp newIntent:intentTypeProcessStart];
    [self NotifyForNormalResponse:DEL_USER_NOTIFICATION intent:intent];
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
-(void) addItelUserBlackResponse:(NSDictionary*)userDic{
    NSString* itelNum = [userDic valueForKey:@"itel"];

    HostItelUser* hostUser = [self getHost];
    if (!hostUser) {
        return;
    }
    NSManagedObjectContext* currentContext =hostUser.managedObjectContext;
    ItelUser* user;
    NSPredicate* findByItelNum = [NSPredicate predicateWithFormat:@"itelNum = %@",itelNum];
    NSArray* matched = [[hostUser.users filteredSetUsingPredicate:findByItelNum] allObjects];
    if ([matched count]) {
        user = matched[0];
    }else{
        user = [ItelUser userWithDictionary:userDic inContext:[IMCoreDataManager defaulManager].managedObjectContext];
    }
    [self.itelBookActionDelegate addUserToBlackBook:user];
    //在block结尾保存数据
    [[IMCoreDataManager defaulManager] saveContext:currentContext];
    id <ItelIntent> intent=[ItelIntentImp newIntent:intentTypeMessage];
    intent.userInfo=@{@"tittle":@"添加成功",@"body":@"该用户已被添加到黑名单中"};
    [self NotifyForNormalResponse:ADD_TO_BLACK_LIST_NOTIFICATION intent:intent];
    
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
#pragma mark - 查询黑名单
- (ItelUser*) queryBlackList:(NSString*) itelNum{
    return [self.itelBookActionDelegate userInBlackBook:itelNum];
}
#pragma  mark - 匹配通讯录好友
/*匹配通讯录中得联系人接口
 1 获得本机所有联系人电话
 2 网络请求
 */
-(void) checkAddressBookMatchingItel{
    
    //    dispatch_queue_t getPhones=dispatch_queue_create("getPhones", NULL);
    //    dispatch_async(getPhones, ^{
    NSArray *phones =  [self.itelBookActionDelegate getAddressPhoneNumbers];
    
    [self.itelNetRequestActionDelegate checkAddressBookForItelUser:phones];
    //    });
    
    
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
    NSManagedObjectContext* currentContext = [IMCoreDataManager defaulManager].managedObjectContext;
    ItelUser *u=[ItelUser userWithDictionary:user inContext:currentContext];
    
    [self.itelBookActionDelegate resetUserInFriendBook:u];
    if (u.isBlack) {
        [self.itelBookActionDelegate resetUserInBlackBook:u];
    }
    [[IMCoreDataManager defaulManager] saveContext:currentContext];
    id <ItelIntent> intent=[ItelIntentImp newIntent:intentTypeReloadData];
    
    [self NotifyForNormalResponse:@"resetAlias" intent:intent];
}
#pragma mark - 查找陌生人
/*
 1 得到查找关键词 发网络请求
 
 */
-(void) searchStranger:(NSString*)searchMessage newSearch:(BOOL)newSearch{
    [self.itelNetRequestActionDelegate searchUser:searchMessage isNewSearch:newSearch];
    
}
//回调
-(void) searchStrangerResponse:(id)response{
    [self NotifyForNormalResponse:SEARCH_STRANGER_NOTIFICATION parameters:response];
}
#pragma mark - 上传图片
-(void)uploadImage:(UIImage*)image{
    NSData *imgData=UIImageJPEGRepresentation(image, 0.1);
//    NSAssert(imgData, @"空的数据");
    //NSData *imgData=UIImageJPEGRepresentation(image, 1);
    NSLog(@"jpeg图片大小：%d",imgData.length);
    HostItelUser *hostUser =  [self.itelUserActionDelegate hostUser];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itelCode":hostUser.itelNum,@"token":hostUser.token};
    [self.itelNetRequestActionDelegate uploadImage:imgData parameters:parameters];
}
//回调
-(void)uploadImageResponse:(NSDictionary*)response{
    
    HostItelUser *hostUser = [self.itelUserActionDelegate hostUser];
    NSString *imageUrl=[response objectForKey:@"data"];
    hostUser.imageUrl=imageUrl;
    [[IMCoreDataManager defaulManager]saveContext:hostUser.managedObjectContext];
    
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
    [self NotifyForNormalResponse:@"modifyPhone" parameters:response];
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
    NSLog(@"%@",parameters);
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
#pragma mark - 启动其他app
-(void)loginOtherApp:(NSDictionary*)type{
    if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"itelFish://itelland.com"]]) {
        
    
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"未发现快鱼，请先安装" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }

    NSDictionary *parameters=@{@"sessiontoken":[self getHost].token,@"type":@"ecommerce-ios",@"phonecode":@""};
    [self.itelNetRequestActionDelegate startOtherApp:parameters];
    
}
-(void)loginOtherAppResponse:(NSDictionary*)data{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: @"itelFish://itelland.com"]]) {
        NSMutableDictionary *login=[data mutableCopy];
       
        NSData *json=[NSJSONSerialization dataWithJSONObject:login options:NSJSONWritingPrettyPrinted error:nil];
        NSString *strParameters=[[[NSString alloc ] initWithData:json encoding:NSUTF8StringEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
        
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"itelFish://itelland.com/?%@",strParameters]];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
             [[UIApplication sharedApplication] openURL:url];
        }else{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"未发现快鱼，请先安装" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
       

    
    
}
}
#pragma mark - 退出登录
-(void)logout{
    HostItelUser *hostUser =[self.itelUserActionDelegate hostUser];
    NSCAppDelegate *app=(NSCAppDelegate*)[UIApplication sharedApplication].delegate;
    NSDictionary *parameters=@{@"itel":hostUser.itelNum,@"onlymark":app.UUID};
    [self.itelNetRequestActionDelegate logout:parameters];
}
-(void)logoutResponse{
    [self NotifyForNormalResponse:@"logout" parameters:nil];
}
#pragma mark - 检查更新
-(void)checkNewVersion:(id)parameters{
    
    [self.itelNetRequestActionDelegate checkForNewVersion:nil];

}
-(void)checkNewVersionResponse:(NSDictionary*)data{
    
    NSArray *infoArray = [data objectForKey:@"results"];
    if (0 == [infoArray count]) {
        NSDictionary* versionNotifyDic = @{
                                           @"msg":@"产品未上架",
                                           @"isNormal":@"0"
                                           };
        
        [self NotifyForNormalResponse:@"checkForNewVersion" parameters:versionNotifyDic];
        return;
    }
    NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
    NSString *latestVersion = [releaseInfo objectForKey:@"version"];
    NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    int latestFirst = [[latestVersion componentsSeparatedByString:@"."][0] intValue];
    int localFisrt = [[version componentsSeparatedByString:@"."][0] intValue];
    NSString *update_level = nil;
    if ( latestFirst - localFisrt > 0) {
        update_level = @"1";
    }else{
        update_level = @"0";
    }
    NSDictionary* versionNotifyDic = @{
                                       @"data":@{
                                         @"update_level":update_level,
                                         @"version":latestVersion,
                                         @"update_url":trackViewUrl
                                               },
                                       @"isNormal":@"1"
                                       };
    
    [self NotifyForNormalResponse:@"checkForNewVersion" parameters:versionNotifyDic];
}
#pragma mark - 远程精确查找
-(void)searchMatchingUserWithItel:(NSString*)itel{
    NSDictionary *parameters=@{@"username": @"186677"};
    [self.itelNetRequestActionDelegate searchMatchingUserWithItel:parameters];
}
-(void)searchMatchingUserWithItelResponse:(NSDictionary*)data{
    [self NotifyForNormalResponse:@"exactlyUser" parameters:data];
    
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
    //TODO:统一保存
}
-(void) NotifyForNormalResponse:(NSString*)name intent:(id<ItelIntent>)intent{
    if (intent!=nil) {
         NSDictionary *userInfo=@{@"isNormal": @"1",@"reason":@"1" ,@"intent":intent };
         [[NSNotificationCenter defaultCenter]postNotificationName:name object:nil userInfo:userInfo];
    }
   
   
   
}
@end
