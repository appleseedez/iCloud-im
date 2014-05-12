//
//  HTTPRequestBuilder+contact.m
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder+contact.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder (contact)
-(RACSignal*)addNewFriend:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/contact/applyItelFriend.json",ACCOUNT_SERVER];
    NSURLRequest *request= [self jsonPostRequestWithUrl:url andParameters:parameters];
    
    return [[HTTPService defaultService] signalWithRequest:request];
}
-(RACSignal*)getFriendList:(NSDictionary*)parameters{
    NSString *url=[NSString stringWithFormat:@"%@/contact/loadItelContacts.json",ACCOUNT_SERVER];
    NSURLRequest *request= [self getRequestWithUrl:url andParameters:parameters];
    
    return [[HTTPService defaultService] signalWithRequest:request];
}
@end
