//
//  NetRequester.h
//  iCloudPhone
//
//  Created by nsc on 13-12-9.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
@interface NetRequester : NSObject
+(void)jsonPostRequestWithUrl:(NSString*)url
                andParameters:(NSDictionary*)parameters
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+(void)jsonGetRequestWithUrl:(NSString*)url
               andParameters:(NSDictionary*)parameters
                     success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+(void)uploadImagePostRequestWithUrl:(NSString*)url
                           imageData:(NSData*)imageData
                       andParameters:(NSDictionary*)parameters
                             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void) checkoutNewVersionFromAppleOnSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+(NSDictionary*)syncJsonPostRequestWithUrl:(NSString*)url parameters:(NSDictionary*)parameters;
@end