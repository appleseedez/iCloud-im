//
//  ItelNetInterfaceImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelNetInterfaceImp.h"
#import "AFNetworking.h"
#import "ItelAction.h"
#import "NetRequester.h"
#import "NXInputChecker.h"

#define  SUCCESS void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
#define  FAILURE void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error)
static ItelNetInterfaceImp* manager;
@implementation ItelNetInterfaceImp
+(void)initialize{
    if (manager==nil) {
        manager=[[ItelNetInterfaceImp alloc]init];
    }
}
+(ItelNetInterfaceImp*)defaultManager{
    return manager;
}
-(void)tearDown{
    manager=nil;
 
   }

-(void)requestWithName:(NSString*)name parameters:(NSDictionary*)parameters Method:(int)method responseSelector:(SEL)selector userInfo:(id)userInfo   notifyName:(NSString*)notifyName{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,name];
    SUCCESS{
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic=(NSDictionary*)json;
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                ItelAction *action=[ItelAction action];
                if ([action respondsToSelector:selector]) {
                    if ([userInfo isEqualToString:@"data"]) {
                        [action performSelector:selector withObject:[dic objectForKey:@"data"]];
                    }else if ([userInfo isEqualToString:@"dic"]){
                        [action performSelector:selector withObject:dic];
                    }
                    else {
                        [action performSelector:selector withObject:userInfo];
                    }
                }
                
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:nil userInfo:userInfo];
        NSLog(@"生命轻轻的 是:%@",error);
    };
    if (method==0) {
        [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
    }
    else if(method==1){
        [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
    }
    
}
#pragma mark - 添加联系人
-(void)addUser:(NSDictionary*)parameters{
    [self requestWithName:ADD_FRIEND_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"inviteItelUserFriendResponse:") userInfo:[parameters valueForKey:@"targetItel"] notifyName:ADD_FIRIEND_NOTIFICATION];
}
#pragma mark - 删除联系人

-(void)delUser:(NSDictionary*)parameters{
    [self requestWithName:DEL_FRIEND_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"delFriendFromItelBookResponse:") userInfo:[parameters objectForKey:@"targetItel"] notifyName:DEL_USER_NOTIFICATION];
}
#pragma mark - 查找用户接口

-(void)searchUser:(NSString*)search isNewSearch:(BOOL)isNewSearch{
    static  int start=0;
    static  int limit=2030;
    if (isNewSearch) {
        start=0;
    }
    else{
        start=start+limit;
    }
    HostItelUser *host = [[ItelAction action] getHost];
   NSDictionary *Parameters=@{@"start":[NSNumber numberWithInt:start],
                               @"limit":[NSNumber numberWithInt:limit],
                               @"keyWord":search,
                               @"token":host.token ,
                               @"hostUserId":host.userId
                               };
    [self requestWithName:SEARCH_USER_INTERFACE parameters:Parameters Method:1 responseSelector:NSSelectorFromString(@"searchStrangerResponse:") userInfo:@"data" notifyName:SEARCH_STRANGER_NOTIFICATION];
    
   }
#pragma mark - 拨打用户电话接口
/*
 待完善
 */
-(void)callUserWithItel:(NSString *)itelNum{
    
}
#pragma mark - 访问用户商店接口
/*
 待完善
 */
-(void)visitUserStore:(NSString *)itelNum{
    
}

#pragma mark - 匹配通讯录中得联系人
/*匹配通讯录中得联系人接口
 1 获得本机所有联系人电话
 2 网络请求
 */
-(void)checkAddressBookForItelUser:(NSArray*)phones{

    HostItelUser *host=[[ItelAction action] getHost];
    NSNumber *number=[NSNumber numberWithInteger:[host.userId intValue] ];
    NSString *strPhones=[NXInputChecker changeArrayToString:phones];
    NSDictionary *parameters=@{@"hostUserId":number, @"numbers":strPhones,@"token":host.token};
    
    [self requestWithName:MATCH_ADDRESS_BOOK_INTERFACE parameters:parameters Method:1 responseSelector:NSSelectorFromString(@"checkAddressBookMatchingResponse:") userInfo:@"data" notifyName:@"checkAddress"];
    
}
#pragma mark - 添加号码到黑名单
-(void)addToBlackList:(NSDictionary*)parameters;{
    [self requestWithName:ADD_USER_BLACK_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"addItelUserBlackResponse:") userInfo:@"data" notifyName:@"addBlack"];
    }

#pragma mark - 从黑名单中移除

-(void)removeFromBlackList:(NSDictionary*)parameters;{
    [self requestWithName:REMOVE_FROM_BLACK_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"delFriendFromBlackResponse:") userInfo:[parameters objectForKey:@"targetItel"] notifyName:@"removeBlack"];
}

#pragma mark - 编辑用户备注
-(void)editUserRemark:(NSString*)newRemark user:(NSDictionary*)parameters{
    [self requestWithName:EDIT_USER_ALIAS_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"editUserAliasResponse:") userInfo:@"data" notifyName:@"resetAlias"];
}

#pragma mark - 刷新好友列表

-(void)refreshUserList:(NSDictionary*)parameters{
    
    [self requestWithName:REFRESH_FRIENDS_LIST_INTERFACE parameters:parameters Method:1 responseSelector:NSSelectorFromString(@"getItelFriendListResponse:") userInfo:@"data" notifyName:@"getItelList"];
}
#pragma mark - 刷新黑名单列表
-(void)refreshBlackList:(NSDictionary*)parameters{
    
    [self requestWithName:REFRESH_BLACK_LIST_INTERFACE parameters:parameters Method:1 responseSelector:NSSelectorFromString(@"getItelBlackListResponse:") userInfo:@"data" notifyName:@"getBlackList"];

}
#pragma mark - 上传图片
-(void)uploadImage:(NSData*)imageData parameters:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,UPLOAD_IMAGE_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic = (NSDictionary*)responseObject;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSLog(@"上传图片,收到的响应%@",dic);
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [[ItelAction action]uploadImageResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyHost" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"网络问题：%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyHost" object:nil userInfo:userInfo];
    };
    [NetRequester uploadImagePostRequestWithUrl:url imageData:imageData andParameters:parameters success:success failure:failure];
}
#pragma  mark - 修改个人资料
-(void) modifyPersonal:(NSDictionary*)parameters{
    [self requestWithName:MODIFY_PERSIONAL_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"modifyPersonalResponse:") userInfo:@"data" notifyName:@"modifyHost"];
   
}
#pragma mark - 修改手机号码-验证新号码
-(void) checkNewTelNum:(NSDictionary*)parameters{
    [self requestWithName:MODIFY_PERSIONAL_TELEPHONE_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"checkPhoneNumberResponse:") userInfo:@"data" notifyName:@"modifyPhone"];
    
}
#pragma mark - 修改手机-提交新手机验证码
-(void) modifyPhoneNumCheckCode:(NSDictionary*)parameters{
    [self requestWithName:MODIFY_PERSIONAL_TELEPHONE_CHECKCODE_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"phoneCheckCodeResponse:") userInfo:[parameters objectForKey:@"phone"] notifyName:@"phoneCheckCode"];
    
}
-(void)resendPhoneMessage:(NSDictionary *)parameters{
    [self requestWithName:MODIFY_PERSIONAL_TELEPHONE_SEND_MESSAGE_CODE_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"resendMassageResponse:") userInfo:@"dic" notifyName:@"resendMes"];
}
#pragma  mark - 修改用户密码
-(void)changePassword:(NSDictionary*)parameters{
    [self requestWithName:MODIFY_PERSIONAL_PASSWORD_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"modifyUserPasswordResponse:") userInfo:@"dic" notifyName:@"changePassword"];
}
#pragma  mark - 密保设置-获得密保
-(void)getPasswordProtection:(NSDictionary*)parameters{
    [self requestWithName:SECURETY_GET_PASSWORD_PROTECTION_INTERFACE parameters:parameters Method:1 responseSelector:NSSelectorFromString(@"checkOutProtectionResponse:") userInfo:@"data" notifyName:@"passwordProtection"];
}
#pragma mark - 密保设置-回答问题
-(void)securetyAnsewerQuestion:(NSDictionary*)parameters{
    [self requestWithName:SECURETY_ANSWER_PROTECTION_QUESTION_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"securetyAnswserQuestionResponse:") userInfo:@"dic" notifyName:@"answerQuestion"];
}
#pragma mark - 修改密保-提交修改
-(void)sendSecuretyProduction:(NSDictionary*)parameters{
    [self requestWithName:SECURETY_MODIFY_PASSWORD_PROTECTION_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"modifySecuretyProductionResponse:") userInfo:@"dic" notifyName:@"modifySecurety"];
}
#pragma mark - 查询新消息
-(void)searchNewMessage:(NSDictionary*)parameters{
    [self requestWithName:MESSAGE_SEARCH_FOR_NEW_MESSAGE_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"searchForNewMessageResponse:") userInfo:@"dic" notifyName:@"searchForNewMessage"];
}
#pragma mark - 刷新消息列表
-(void)refreshForNewMessage:(NSDictionary*)parameters{
    [self requestWithName:MESSAGE_REFRESH_MESSAGE_LIST_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"getNewMessageResponse:") userInfo:@"dic" notifyName:@"getNewMessage"];
}
#pragma mark - 接受邀请
-(void)acceptIvitation:(NSDictionary*)parameters{
    [self requestWithName:MESSAGE_ACCEPT_INVITITION_INTERFACE parameters:parameters Method:0 responseSelector:NSSelectorFromString(@"acceptFriendIvicationResponse:") userInfo:@"dic" notifyName:@"acceptFriends"];
}
-(void)logout:(NSDictionary*)parameters{
    [self requestWithName:@"/j_spring_security_logout" parameters:parameters Method:1 responseSelector:Nil userInfo:Nil notifyName:@"null"];
    
}
@end
