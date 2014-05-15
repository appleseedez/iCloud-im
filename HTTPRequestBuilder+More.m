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
@end
