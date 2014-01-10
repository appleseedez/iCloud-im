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
#pragma mark - 添加联系人
static int addcount=0;

-(void)addUser:(NSDictionary*)parameters{
    addcount++;
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,ADD_FRIEND_INTERFACE];
    SUCCESS{
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic=(NSDictionary*)json;
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSString *itel=[parameters objectForKey:@"targetItel"];
                [[ItelAction action] inviteItelUserFriendResponse:itel];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:ADD_FIRIEND_NOTIFICATION object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_FIRIEND_NOTIFICATION object:nil userInfo:userInfo];
        NSLog(@"生命轻轻的 是:%@",error);
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 删除联系人

-(void)delUser:(NSDictionary*)parameters{
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,DEL_FRIEND_INTERFACE];
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            NSString *itel=[parameters objectForKey:@"targetItel"];
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [[ItelAction action] delFriendFromItelBookResponse:itel];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:DEL_USER_NOTIFICATION object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:DEL_USER_NOTIFICATION object:nil userInfo:userInfo];
        NSLog(@"%@",error);
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
    
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
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,SEARCH_USER_INTERFACE];
    //post参数
    NSDictionary *Parameters=@{@"start":[NSNumber numberWithInt:start],
                               @"limit":[NSNumber numberWithInt:limit],
                               @"keyWord":search,
                               @"token":host.token ,
                               @"hostUserId":host.userId
                               };
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                BOOL isEnd=0;
                int rtotal=[[dic objectForKey:@"total"] intValue];
                int rstart=[[dic objectForKey:@"start"] intValue];
                int rlimit=[[dic objectForKey: @"limit"] intValue];
                if (rtotal>rstart+rlimit) {
                    isEnd=0;
                }
                else {
                    isEnd=1;
                }
                
                id data =[dic objectForKey:@"data"];
                // NSArray *list=[data objectForKey:@"list"];
                //NSLog(@"查找陌生人：服务器返回%d条数据",[list count]);
                
                [[ItelAction action] searchStrangerResponse:data isEnd:isEnd];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_STRANGER_NOTIFICATION object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_STRANGER_NOTIFICATION object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:Parameters success:success failure:failure];
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
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MATCH_ADDRESS_BOOK_INTERFACE];
    
    HostItelUser *host=[[ItelAction action] getHost];
    NSNumber *number=[NSNumber numberWithInteger:[host.userId intValue] ];
    NSString *strPhones=[NXInputChecker changeArrayToString:phones];
    
    NSDictionary *parameters=@{@"hostUserId":number, @"numbers":strPhones,@"token":host.token};
    SUCCESS {
        
        dispatch_queue_t getPhones=dispatch_queue_create("getPhones", NULL);
        dispatch_async(getPhones, ^{
            
            id dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:Nil];
            
            if ([dic isKindOfClass:[NSDictionary class]]) {
                
                int ret=[[dic objectForKey:@"ret"] intValue];
                if (ret==0) {
                    NSArray *itelusers=[dic objectForKey:@"data"];
                    NSLog(@"匹配通讯录:服务器返回%d条数据",[itelusers count]);
                    
                    if ([itelusers count]) {
                        ItelAction *action = [ItelAction action];
                        [action checkAddressBookMatchingResponse:itelusers];
                    }
                }
                else {
                    NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkAddress" object:nil userInfo:userInfo];
                }
            }  });//如果请求失败 则执行failure
    };
    FAILURE{
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkAddress" object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 添加号码到黑名单
-(void)addToBlackList:(NSDictionary*)parameters;{
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,ADD_USER_BLACK_INTERFACE];
    SUCCESS{
        
        NSError *error=nil;
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action] addItelUserBlackResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"addBlack" object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addBlack" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}

#pragma mark - 从黑名单中移除

-(void)removeFromBlackList:(NSDictionary*)parameters;{
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,REMOVE_FROM_BLACK_INTERFACE];
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            NSString *itel=[parameters objectForKey:@"targetItel"];
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                
                [[ItelAction action] delFriendFromBlackResponse:itel];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removeBlack" object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeBlack" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}

#pragma mark - 编辑用户备注
-(void)editUserRemark:(NSString*)newRemark user:(NSDictionary*)parameters{
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,EDIT_USER_ALIAS_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action] editUserAliasResponse:[dic objectForKey:@"data"]];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"resetAlias" object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resetAlias" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}

#pragma mark - 刷新好友列表

-(void)refreshUserList:(NSDictionary*)parameters{
    
    
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,REFRESH_FRIENDS_LIST_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                
                id data =[dic objectForKey:@"data"];
                [[ItelAction action] getItelFriendListResponse:data ];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getItelList" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getItelList" object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
    
}
#pragma mark - 刷新黑名单列表
-(void)refreshBlackList:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,REFRESH_BLACK_LIST_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                
                NSArray *list=[[dic objectForKey:@"data"] objectForKey:@"list"];
                NSLog(@"刷新黑名单：返回数据%d条",[list count]);
                id data =[dic objectForKey:@"data"];
                [[ItelAction action] getItelBlackListResponse:data];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getBlackList" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getBlackList" object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
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
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MODIFY_PERSIONAL_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                id data =[dic objectForKey:@"data"];
                [[ItelAction action] modifyPersonalResponse:data];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"解析异常" };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyHost" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyHost" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 修改手机号码-验证新号码
-(void) checkNewTelNum:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MODIFY_PERSIONAL_TELEPHONE_INTERFACE];
    
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [[ItelAction action] checkPhoneNumberResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyPhone" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyPhone" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 修改手机-提交新手机验证码
-(void) modifyPhoneNumCheckCode:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MODIFY_PERSIONAL_TELEPHONE_CHECKCODE_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                id data =[dic objectForKey:@"data"];
                [[ItelAction action]  phoneCheckCodeResponse:data];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"phoneCheckCode" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"phoneCheckCode" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
    
}
-(void)resendPhoneMessage:(NSDictionary *)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MODIFY_PERSIONAL_TELEPHONE_SEND_MESSAGE_CODE_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action]  resendMassageResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"resendMes" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"resendMes" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma  mark - 修改用户密码
-(void)changePassword:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MODIFY_PERSIONAL_PASSWORD_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [[ItelAction action]  modifyUserPasswordResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"changePassword" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changePassword" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma  mark - 密保设置-获得密保
-(void)getPasswordProtection:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,SECURETY_GET_PASSWORD_PROTECTION_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSDictionary *data=(NSDictionary*)[dic objectForKey:@"data"];
                [[ItelAction action] checkOutProtectionResponse:data];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passwordProtection" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"passwordProtection" object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 密保设置-回答问题
-(void)securetyAnsewerQuestion:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,SECURETY_ANSWER_PROTECTION_QUESTION_INTERFACE];
    
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action] securetyAnswserQuestionResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"answerQuestion" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"answerQuestion" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 修改密保-提交修改
-(void)sendSecuretyProduction:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,SECURETY_MODIFY_PASSWORD_PROTECTION_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action] modifySecuretyProductionResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"modifySecurety" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifySecurety" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 查询新消息
-(void)searchNewMessage:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MESSAGE_SEARCH_FOR_NEW_MESSAGE_INTERFACE];
    
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action] searchForNewMessageResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"searchForNewMessage" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchForNewMessage" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
    
}
#pragma mark - 刷新消息列表
-(void)refreshForNewMessage:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MESSAGE_REFRESH_MESSAGE_LIST_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            NSLog(@"返回的message:%@",[dic valueForKey:@"msg"]);
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action]getNewMessageResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"getNewMessage" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"getNewMessage" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 接受邀请
-(void)acceptIvitation:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@%@",SIGNAL_SERVER,MESSAGE_ACCEPT_INVITITION_INTERFACE];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                [[ItelAction action]acceptFriendIvicationResponse:dic];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptFriends" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"acceptFriends" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
-(void)logout:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/CloudCommunity/j_spring_security_logout",SIGNAL_SERVER];
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                
            }
            else {
                // NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        // NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil userInfo:userInfo];
    };
    [NetRequester jsonGetRequestWithUrl:url andParameters:@{} success:success failure:failure];
}
@end
