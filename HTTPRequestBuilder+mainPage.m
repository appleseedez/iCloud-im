//
//  HTTPRequestBuilder+mainPage.m
//  itelNSC
//
//  Created by nsc on 14-5-9.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+mainPage.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (mainPage)
-(RACSignal*)loadADImages{
    NSString *str=[NSString stringWithFormat:@"%@/user/getAdvanceImage.json",ACCOUNT_SERVER];
    NSURLRequest *request=  [self  jsonPostRequestWithUrl:str andParameters:@{}];
    return [[HTTPService defaultService] signalWithRequest:request];
}
@end
