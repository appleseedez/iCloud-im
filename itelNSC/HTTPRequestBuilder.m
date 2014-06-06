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
        instance.delegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
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
    
    NSMutableDictionary *tokenParameters=[parameters mutableCopy];
   
    NSString *token=[self.delegate.loginInfo objectForKey:@"sessiontoken"];
    
    if (token) {
        [tokenParameters setValue:token forKey:@"sessiontoken"];
    }
    
    
    
    
   return  [[AFJSONRequestSerializer serializer] requestWithMethod:@"get" URLString:url parameters:tokenParameters error:nil]  ;
  
}

@end
