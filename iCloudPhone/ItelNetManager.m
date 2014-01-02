    //
//  ItelNetManager.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelNetManager.h"
#import "AFNetworking.h"
#import "ItelAction.h"
#import "NXInputChecker.h"
#import "HostItelUser.h"
#import "NetRequester.h"
#define  SUCCESS void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
#define  FAILURE void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error)
static NSString *server=@"http://211.149.144.15:8000/CloudCommunity";
//static NSString *server=@"http://10.0.0.137:8080/CloudCommunity";

static ItelNetManager *manager=nil;
@implementation ItelNetManager

+(ItelNetManager*)defaultManager{
    
    if (manager==nil) {
        manager=[[ItelNetManager alloc]init];
    }
   
    return manager;
}

#pragma mark - 添加联系人
static int addcount=0;

-(void)addUser:(NSDictionary*)parameters{
    addcount++;
    //NSLog(@"一共添加%d次联系人",addcount);
    
    NSString *url=[NSString stringWithFormat:@"%@/contact/applyItelFriend.json",server];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteItelUser" object:nil userInfo:userInfo];
            }
            }
    };
    FAILURE{
         NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
          [[NSNotificationCenter defaultCenter] postNotificationName:@"inviteItelUser" object:nil userInfo:userInfo];
        };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 删除联系人

-(void)delUser:(NSDictionary*)parameters{
  
      NSString *url=[NSString stringWithFormat:@"%@/contact/removeItelFriend.json",server];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:@"delItelUser" object:nil userInfo:userInfo];
            }
        }
    };
    FAILURE{
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"delItelUser" object:nil userInfo:userInfo];
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
    NSString *url=[NSString stringWithFormat:@"%@/contact/searchUser.json",server];
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
                    NSArray *list=[data objectForKey:@"list"];
                    NSLog(@"查找陌生人：服务器返回%d条数据",[list count]);

                    [[ItelAction action] searchStrangerResponse:data isEnd:isEnd];
                    }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"searchStranger" object:nil userInfo:userInfo];
               }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchStranger" object:nil userInfo:userInfo];
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
    
    NSString *url=[NSString stringWithFormat:@"%@/contact/matchLocalContactsUser.json",server];
   
    HostItelUser *host=[[ItelAction action] getHost];
    NSNumber *number=[NSNumber numberWithInteger:[host.userId intValue] ];
    NSString *strPhones=[NXInputChecker changeArrayToString:phones];
//    strPhones =[NSString stringWithFormat:@"%@,15799990000,15899990000,15899990001,15699990000,15399990000,15899990022",strPhones];
    
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
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"checkAddress" object:nil userInfo:userInfo];
      };
    [NetRequester jsonGetRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 添加号码到黑名单
-(void)addToBlackList:(NSDictionary*)parameters;{
   
    NSString *url=[NSString stringWithFormat:@"%@/blacklist/addItelBlack.json",server];
    SUCCESS{
        
        NSError *error=nil;
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            NSString *itel=[parameters objectForKey:@"targetItel"];
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
               
                [[ItelAction action] addItelUserBlackResponse:itel];
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
   
    NSString *url=[NSString stringWithFormat:@"%@/blacklist/removeItelBlack.json",server];
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
   
    NSString *url=[NSString stringWithFormat:@"%@/contact/updateItelFriend.json",server];

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
    
    
   NSString *url=[NSString stringWithFormat:@"%@/contact/loadItelContacts.json",server];
   
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
    NSString *url=[NSString stringWithFormat:@"%@/blacklist/loadItelBlackLists.json",server];
    
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
    NSString *url=[NSString stringWithFormat:@"%@/upload/uploadImg.json",server];
    
    SUCCESS{
        NSDictionary *dic = (NSDictionary*)responseObject;
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
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
    NSString *url=[NSString stringWithFormat:@"%@/user/updateUser.json",server];
    
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
    NSString *url=[NSString stringWithFormat:@"%@/com/isRepeatPhone.json",server];
 
   
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
        NSLog(@"%@",error);
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyPhone" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
#pragma mark - 修改手机-提交新手机验证码
-(void) modifyPhoneNumCheckCode:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/modifyPhone.json",server];
    
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
    NSString *url=[NSString stringWithFormat:@"%@/com/sendMassageByPhone.json",server];
    
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
    NSString *url=[NSString stringWithFormat:@"%@/safety/updatePassword.json",server];
  
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
    NSString *url=[NSString stringWithFormat:@"%@/safety/getPasswordProtection.json",server];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSLog(@"%@",dic);
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
    NSString *url=[NSString stringWithFormat:@"%@/safety/checkPasswordProtection.json",server];
    

    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSLog(@"%@",dic);
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
    NSString *url=[NSString stringWithFormat:@"%@/safety/saveOrUpdatePasswordProtection.json",server];
    
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
    NSString *url=[NSString stringWithFormat:@"%@/contact/isApplyMsg.json",server];
   
    
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
    NSString *url=[NSString stringWithFormat:@"%@/contact/getApplyMsg.json",server];
    
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
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
    NSString *url=[NSString stringWithFormat:@"%@/contact/submitApply.json",server];
    
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
@end
