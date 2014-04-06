//
//  RAC_NetRequest_Signal.m
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "RAC_NetRequest_Signal.h"
#import "ItelAction.h"
#import "ReactiveCocoa.h"
#import "AFNetworking.h"
@implementation RAC_NetRequest_Signal
+(RACSignal*)signalWithUrl:(NSString*)url
                            parameters:(NSDictionary*)parameters
                                  type:(NSInteger)type
{
    NSURLRequest *request;
    if(type==0){
        request= [self JSONGetOperation:url parameters:parameters];
    }else{
        request=[self JSONPostOperation:url parameters:parameters];
    }
    
   RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
       
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            NSData *responseObject;
            NSURLResponse *response;
          responseObject=  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            if (error) {
                [subscriber sendError:error];
            }else {
                NSString *str=[[NSString alloc]initWithData:responseObject encoding:4];
                NSLog(@"%@",str);
                
                NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                [subscriber sendNext:dic];
            
            }
        });
       
       
       return nil;
   }];

    
    return signal;
}
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
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    return request;
}
@end
