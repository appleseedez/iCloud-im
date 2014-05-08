//
//  HTTPRequestBuilder.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder.h"
#import "NSString+MD5.h"
#import "MaoAppDelegate.h"
#import "HTTPService.h"
@implementation HTTPRequestBuilder
static HTTPRequestBuilder *instance;
+(HTTPRequestBuilder*)defaultBuilder{
    
  
    
    return instance;
}
+(void)initialize{
    static BOOL initialized=NO;
    if (initialized==NO) {
        instance=[[HTTPRequestBuilder alloc]init];
        instance.delegate=[UIApplication sharedApplication].delegate;
        initialized=YES;
    }
}
-(NSURLRequest*)jsonPostRequestWithUrl:(NSString*)url
                andParameters:(NSDictionary*)parameters
                      {
                         
    NSString *token=[self.delegate.loginInfo objectForKey:@"sessiontoken"];
    
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

-(NSURLRequest*)getRequestWithUrl:(NSString*)url andParameters:(NSDictionary*)parameters{
    NSString *paraStr=nil;
    for (NSString *key in [parameters allKeys]) {
        NSInteger i=[[parameters allKeys] indexOfObject:key];
        if (i==0) {
            paraStr=[NSString stringWithFormat:@"%@=%@",key, [parameters objectForKey:key]];
        }else{
            paraStr=[NSString stringWithFormat:@"%@&%@=%@",paraStr,key,[parameters objectForKey:key]];
        }
    }
    NSString *getUrl=[NSString stringWithFormat:@"%@?%@",url,paraStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:getUrl]];
    
    return request;
}
@end
