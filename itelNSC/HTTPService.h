//
//  HTTPService.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPService : NSObject
@property (nonatomic) NSOperationQueue *httpQueue;
+(HTTPService*)defaultService;
-(RACSignal*)signalWithRequest:(NSURLRequest*)request;
-(void)uploadImagePostRequestWithUrl:(NSString*)url
                           imageData:(NSData*)imageData
                       andParameters:(NSDictionary*)parameters
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
