//
//  HTTPService.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPService.h"
#import "MaoAppDelegate.h"
@implementation HTTPService
static HTTPService *instance=nil;
+(HTTPService*)defaultService{
   
    return instance;
}

+(void)initialize{
    static BOOL initialized=NO;
    if (initialized==NO) {
        instance=[[HTTPService alloc]init];
        initialized=YES;
    }
}
-(NSOperationQueue*)httpQueue{
    if (_httpQueue==nil) {
        _httpQueue=[[NSOperationQueue alloc]init];
        [_httpQueue setMaxConcurrentOperationCount:6];
        [_httpQueue setName:@"HTTP_QUEUE"];
    }
    return _httpQueue;
}
-(RACSignal*)signalWithRequest:(NSURLRequest*)request{
    
          RACSignal *signal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [NSURLConnection sendAsynchronousRequest:request queue:self.httpQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             if (connectionError) {
                                 [subscriber sendError:connectionError];
                             }else{
                                 NSError *error=nil;
                                 id object=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                                 if (error) {
                                     [subscriber sendNext:data];
                                 }else{
                                 [subscriber sendNext:object];
                                 }
                                 [subscriber sendCompleted];
                             }
                            });
                }];
              return nil;
          }];
    
    return signal;
}
-(void)uploadImagePostRequestWithUrl:(NSString*)url
                           imageData:(NSData*)imageData
                       andParameters:(NSDictionary*)parameters
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    NSDictionary *loginInfo=((MaoAppDelegate*)[UIApplication sharedApplication].delegate).loginInfo;
    NSString *token=[loginInfo objectForKey:@"sessiontoken"];;
    
    if (token) {
        url=[NSString stringWithFormat:@"%@?sessiontoken=%@",url,token];
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData    name:@"image" fileName:@"header.png" mimeType:@"image/png"];
    } success:success failure:failure];
    //NSLog(@"%@",url);
    
}
@end
