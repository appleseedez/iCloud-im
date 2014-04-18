//
//  NetRequestBuilder.m
//  iCloudPhone
//
//  Created by nsc on 14-4-18.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "NetRequestBuilder.h"
#import "ItelAction.h"
#import "AFNetworking.h"
@implementation NetRequestBuilder
+(NSURLRequest*)JSONPostRequset:(NSDictionary*)parameters url:(NSString*)url{
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
+(NSURLRequest*)getRequest:(NSDictionary*)parameters url:(NSString*)url{
    
    NSMutableDictionary *tokenParameters=[parameters mutableCopy];
    NSString *token=[[ItelAction action] getHost].token;
    
    if (token) {
        [tokenParameters setValue:token forKey:@"sessiontoken"];
    }
    
    
    
    
    NSMutableURLRequest *request=[[AFJSONRequestSerializer serializer] requestWithMethod:@"get" URLString:url parameters:tokenParameters];
    
    return request;
  
}

@end
