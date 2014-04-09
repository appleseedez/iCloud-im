//
//  RAC_NetRequest_Signal.m
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "RAC_NetRequest_builder.h"
#import "ItelAction.h"

#import "AFNetworking.h"
@implementation RAC_NetRequest_builder
+(NSURLRequest*)JSONPostOperation:(NSString*)url parameters:(NSDictionary*)parameters{
    NSString *token=[[ItelAction action] getHost].token;
    
    if (token) {
        url=[NSString stringWithFormat:@"%@?sessiontoken=%@",url,token];
    }
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData *httpBody=[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:httpBody];
   
    

    return request;
}
+(NSURLRequest*)JSONGetOperation:(NSString*)url parameters:(NSDictionary*)parameters{
    NSMutableDictionary *tokenParameters=[parameters mutableCopy];
    NSString *token=[[ItelAction action] getHost].token;
   
    if (token) {
        [tokenParameters setValue:token forKey:@"sessiontoken"];
    }
    
    
    NSData *json=[NSJSONSerialization dataWithJSONObject:tokenParameters options:NSJSONWritingPrettyPrinted error:nil];
    NSString *paraURL=[[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
    
    NSURL *uurl=[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",url,paraURL]];
    NSURLRequest *request=[NSURLRequest requestWithURL:uurl];
   
    return request;
}
@end
