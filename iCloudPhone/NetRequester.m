//
//  NetRequester.m
//  iCloudPhone
//
//  Created by nsc on 13-12-9.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "NetRequester.h"
#import "ItelAction.h"
@implementation NetRequester

+(void)jsonPostRequestWithUrl:(NSString*)url
                andParameters:(NSDictionary*)parameters
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSString *token=[[ItelAction action] getHost].token;
    
    if (token) {
        url=[NSString stringWithFormat:@"%@?sessiontoken=%@",url,token];
    }
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    for (NSString *s in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
#if OTHER_MESSAGE
//        NSLog(@"目前的cookie值为:%@",s);
#endif
    }
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData *httpBody=[NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:httpBody];
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
    
    //NSLog(@"%@",url);
}
+(void)jsonGetRequestWithUrl:(NSString*)url
               andParameters:(NSDictionary*)parameters
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
     NSMutableDictionary *tokenParameters=[parameters mutableCopy];
    NSString *token=[[ItelAction action] getHost].token;
    
    if (token) {
        [tokenParameters setValue:token forKey:@"sessiontoken"];
    }

   
    
    
    NSMutableURLRequest *request=[[AFJSONRequestSerializer serializer] requestWithMethod:@"get" URLString:url parameters:tokenParameters];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
    //NSLog(@"%@",request.URL);
    
}
+(NSDictionary*)syncJsonPostRequestWithUrl:(NSString*)url parameters:(NSDictionary*)parameters{
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
    NSURLResponse *response=nil;
    NSError *error=nil;
    NSData *responseData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error) {
        NSLog(@"%@",error);
        return nil;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        return dic;
    }
    return nil;
    
}
+(void)uploadImagePostRequestWithUrl:(NSString*)url
                           imageData:(NSData*)imageData
                       andParameters:(NSDictionary*)parameters
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    NSString *token=[[ItelAction action] getHost].token;
    
    if (token) {
        url=[NSString stringWithFormat:@"%@?sessiontoken=%@",url,token];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData    name:@"image" fileName:@"header.png" mimeType:@"image/png"];
    } success:success failure:failure];
    //NSLog(@"%@",url);
    
}


+ (void) checkoutNewVersionFromAppleOnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@",APPID]  parameters:nil success:success failure:failure];
}

@end
