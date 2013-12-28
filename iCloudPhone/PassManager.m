//
//  PassManager.m
//  iCloudPhone
//
//  Created by nsc on 13-12-27.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassManager.h"
#import "AFNetworking.h"
#import "NetRequester.h"
static PassManager *manager=nil;
#define  SUCCESS void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
#define  FAILURE void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error)
@implementation PassManager
+(PassManager*)defaultManager{
    if (manager==nil) {
        manager=[[PassManager alloc] init];
    }
    return manager;
}
-(void) checkMessageCode:(NSString*)code{
    NSString *url = @"http://10.0.0.150:8080/CloudCommunity/com/modifyPhone.json";
    NSDictionary *parameters=@{@"userId":self.userId ,@"itelCode":self.itel,@"token":@"fdffafaf",@"captcha":code,@"phone":self.telephone};
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passPhoneCheckCode" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"passPhoneCheckCode" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];

}
-(void) sendMessage{
    //NSString *url=[NSString stringWithFormat:@"%@/com/sendMassageByPhone.json",server];
    NSString *url = @"http://10.0.0.150:8080/CloudCommunity/com/sendMassageByPhone.json";
    NSDictionary *parameters=@{@"userId":self.userId ,@"itelCode":self.itel,@"token":@"sfafgwqfgq",@"phone":self.telephone};
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                
                
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
-(void) modifyPassword:(NSString*)password{
    //NSString *url=[NSString stringWithFormat:@"%@/safety/updatePassword.json",server];
   NSString *url = @"http://10.0.0.150:8080/CloudCommunity/safety/resetPassword.json";
       NSDictionary *parameters=@{@"itel":self.itel ,@"token":@"asdafaasf",@"password":password,};
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSDictionary *userInfo=@{@"isNormal": @"1",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passChangePassword" object:dic userInfo:userInfo];
            }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passChangePassword" object:dic userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"passChangePassword" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];

}
-(void) answerQuestion:(NSString*)question answer:(NSString*)answer{
   // NSString *url=[NSString stringWithFormat:@"%@/safety/checkPasswordProtection.json",server];
   NSString *url = @"http://10.0.0.150:8080/CloudCommunity/safety/checkPasswordProtection.json";
    NSDictionary *parameters=@{@"question": question,
                               @"answer":answer,
                               @"userId":self.userId,
                               @"token":@"fdsdfdadfewt"
                               };
    NSLog(@"%@",parameters);
    SUCCESS{
        NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([dic isKindOfClass:[NSDictionary class]]) {
            
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                NSDictionary *userInfo=@{@"isNormal": @"1",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passAnswerQuestion" object:nil userInfo:userInfo];
                }
            else {
                NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":[dic objectForKey:@"msg"] };
                [[NSNotificationCenter defaultCenter] postNotificationName:@"passAnswerQuestion" object:nil userInfo:userInfo];
            }
        }//如果请求失败 则执行failure
    };
    FAILURE {
        
        NSDictionary *userInfo=@{@"isNormal": @"0",@"reason":@"网络异常" };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"passAnswerQuestion" object:nil userInfo:userInfo];
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];

}

@end
