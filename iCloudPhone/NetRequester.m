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
//    HostItelUser *host= [[ItelAction action] getHost];
//    
//    if (host.sessionId) {
//       
//    
//    NSMutableDictionary *cookieJSESSIONID = [NSMutableDictionary dictionary];
//    [cookieJSESSIONID setObject:@"JSESSIONID" forKey:NSHTTPCookieName];
//    [cookieJSESSIONID setObject:host.sessionId forKey:NSHTTPCookieValue];
//    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieJSESSIONID];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    
//    NSMutableDictionary *SPRING_SECURITY_REMEMBER_ME_COOKIE = [NSMutableDictionary dictionary];
//    [SPRING_SECURITY_REMEMBER_ME_COOKIE setObject:@"SPRING_SECURITY_REMEMBER_ME_COOKIE" forKey:NSHTTPCookieName];
//    [SPRING_SECURITY_REMEMBER_ME_COOKIE setObject:host.SPRING_SECURITY_REMEMBER_ME_COOKIE forKey:NSHTTPCookieValue];
//    NSHTTPCookie *cookie1 = [NSHTTPCookie cookieWithProperties:SPRING_SECURITY_REMEMBER_ME_COOKIE];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie1];
//        if (host.token==nil||[host.token isEqual:[NSNull null]]) {
//             host.token=@"";
//        }
//        
//    NSMutableDictionary *cookieToken = [NSMutableDictionary dictionary];
//    [cookieToken setObject:@"token" forKey:NSHTTPCookieName];
//    [cookieToken setObject:host.token forKey:NSHTTPCookieValue];
//    NSHTTPCookie *cookie2 = [NSHTTPCookie cookieWithProperties:cookieToken];
//    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie2];
//    }
    
    for (NSString *s in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
#if OTHER_MESSAGE
        NSLog(@"目前的cookie值为:%@",s);
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
    NSLog(@"上传接口:%@",url);
        [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:imageData     name:@"image" fileName:@"header.png" mimeType:@"image/png"];
    } success:success failure:failure];
    
    //分界线的标识符
//    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
//    //根据url初始化request
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:10];
//    //分界线 --AaB03x
//    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
//    //结束符 AaB03x--
//    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
//    //要上传的图片
//       //http body的字符串
//    NSMutableString *body=[[NSMutableString alloc]init];
//    //参数的集合的所有key的集合
//    NSArray *keys= [parameters allKeys];
//    
//    //遍历keys
//    for(int i=0;i<[keys count];i++)
//    {
//        //得到当前key
//        NSString *key=[keys objectAtIndex:i];
//        //如果key不是pic，说明value是字符类型，比如name：Boris
//        if(![key isEqualToString:@"pic"])
//        {
//            //添加分界线，换行
//            [body appendFormat:@"%@\r\n",MPboundary];
//            //添加字段名称，换2行
//            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
//            //添加字段的值
//            [body appendFormat:@"%@\r\n",[parameters objectForKey:key]];
//        }
//    }
//    
//    ////添加分界线，换行
//    [body appendFormat:@"%@\r\n",MPboundary];
//    //声明pic字段，文件名为boris.png
//    [body appendFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"image\"\r\n"];
//    //声明上传文件的格式
//    [body appendFormat:@"Content-Type: image/jpeg\r\n\r\n"];
//    
//    //声明结束符：--AaB03x--
//    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
//    //声明myRequestData，用来放入http body
//    NSMutableData *myRequestData=[NSMutableData data];
//    //将body字符串转化为UTF8格式的二进制
//    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
//    //将image的data加入
//    [myRequestData appendData:imageData];
//    //加入结束符--AaB03x--
//    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    //设置HTTPHeader中Content-Type的值
//    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
//    //设置HTTPHeader
//    [request setValue:content forHTTPHeaderField:@"Content-Type"];
//    //设置Content-Length
//    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
//    //设置http body
//    [request setHTTPBody:myRequestData];
//    
//    NSData *img=imageData;
//    NSString *str=[[NSString alloc]initWithData:myRequestData encoding:NSUTF8StringEncoding];
//    NSLog(@"%@",str);
//    //http method
//    [request setHTTPMethod:@"POST"];
//    
//    //建立连接
//    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError) {
//            NSLog(@"%@",connectionError);
//        }
//        else{
//            NSError *error=nil;
//            id json=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
//            NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//            NSLog(@"%@",str);
//            NSLog(@"%@",json);
//        }
//        
//    }];
   }

@end
