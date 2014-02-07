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
    
}
+(void)jsonGetRequestWithUrl:(NSString*)url
               andParameters:(NSDictionary*)parameters
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    NSMutableURLRequest *request=[[AFJSONRequestSerializer serializer] requestWithMethod:@"get" URLString:url parameters:parameters];
    
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
    
}
+(void)uploadImagePostRequestWithUrl:(NSString*)url
                           imageData:(NSData*)imageData
                       andParameters:(NSDictionary*)parameters
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
        NSLog(@"上传图片的长度:%d",imageData.length);
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData    name:@"image" fileName:@"header.png" mimeType:@"image/png"];
    } success:success failure:failure];
    
   }

@end
