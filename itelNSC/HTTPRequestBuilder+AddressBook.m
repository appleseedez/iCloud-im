//
//  HTTPRequestBuilder+AddressBook.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+AddressBook.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (AddressBook)
-(RACSignal*)loadAddressBook:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/contact/matchLocalContactsUser.json",ACCOUNT_SERVER];
    NSURLRequest *request= [self getRequestWithUrl:url andParameters:parameters];
   return  [[HTTPService defaultService] signalWithRequest:request];
}
@end
