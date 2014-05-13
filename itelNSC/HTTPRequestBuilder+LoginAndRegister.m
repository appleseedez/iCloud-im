//
//  HTTPRequestBuilder+LoginAndRegister.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-7.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+LoginAndRegister.h"
#import "MaoAppDelegate.h"
#import "NSString+MD5.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (LoginAndRegister)
-(RACSignal*)login:(NSString*)itel password:(NSString*)password{
    NSString *url=[NSString stringWithFormat:@"%@/login.json",ACCOUNT_SERVER];
    
    
    
    NSString *uuid=self.delegate.UUID;
    if (uuid==nil) {
        
        NSError *error=[NSError errorWithDomain:@"======================================UUID为空" code:2231 userInfo:nil];
        
        return [RACSignal error:error];
    }
    
    
    
    
    password=[password MD5];
    
    NSDictionary *parameters=  @{@"itel": itel,@"password":password,@"type":@"phone-ios",@"onlymark":uuid,@"phonecode":@""};
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    
    return  [[HTTPService defaultService] signalWithRequest:request];
    
    
}
-(RACSignal*)regCheckItel:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/register/registerSubmitByJson.json",ACCOUNT_SERVER];
    
    NSURLRequest *request=  [self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)regSendMessage:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/register/checkPhoneByJson.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
    
}
-(RACSignal*)passSendMessage:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/sendMassageByPhone.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
    
}
-(RACSignal*)regCheckMesCode:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/register/submitPhoneOkByJson.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)regGetRandomNumbers{
    NSString *str=[NSString stringWithFormat:@"%@/register/getItelList.json",ACCOUNT_SERVER];
    NSURL *url=[NSURL URLWithString:str];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passGetToken{
    NSString *strurl=[NSString stringWithFormat:@"%@/initToken.json",ACCOUNT_SERVER];
    
    
    NSURL *url  =[NSURL URLWithString:strurl];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:3];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passGetCodeImage:(NSString*)token{
    NSString *strurl=[NSString stringWithFormat:@"%@/printImage",ACCOUNT_SERVER];
    
    NSString *parameterUrl=[NSString stringWithFormat:@"%@?token=%@",strurl,token];
    NSURL *url  =[NSURL URLWithString:parameterUrl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passCheckToken:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/checkImgCodeItel.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passCheckPhoneCode:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/checkPhoneCode.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passSendNewPassword:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/resetPassword.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passAnswerQuestion:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/checkPasswordProtection.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passSendEmail:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/user/sendEmailCode.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self getRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)passCheckEmailCode:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/user/passwordEmailCode.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self getRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}

@end
