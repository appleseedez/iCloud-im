//
//  HTTPRequestBuilder+More.m
//  itelNSC
//
//  Created by nsc on 14-5-15.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+More.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (More)
-(RACSignal*)modifyHost:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/user/updateUser.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)checkPhoneNumber:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/isRepeatPhone.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)moreSendMessager:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/sendMassageByPhone.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)checkCodeNumber:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/com/modifyPhone.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)loadBlackList:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/blacklist/loadItelBlackLists.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self getRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)removeFromBlackList:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/blacklist/removeItelBlack.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)changePassword:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/updatePassword.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)getUserSecurity:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/getPasswordProtection.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self getRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)checkUserAnswer:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/checkPasswordProtection.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)modifyProtection:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/safety/saveOrUpdatePasswordProtection.json",ACCOUNT_SERVER];
    NSURLRequest *request=[self jsonPostRequestWithUrl:url andParameters:parameters];
    return [[HTTPService defaultService] signalWithRequest:request];
}
@end
