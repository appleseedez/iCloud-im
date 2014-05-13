//
//  HTTPRequestBuilder+app.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+app.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (app)
-(RACSignal*)logout:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/logoutSuccess.do",ACCOUNT_SERVER];
    NSMutableURLRequest *request=[[self getRequestWithUrl:url andParameters:parameters] mutableCopy];
    [request setTimeoutInterval:3];
    return [[HTTPService defaultService] signalWithRequest:request];
}
@end
