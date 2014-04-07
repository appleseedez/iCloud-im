//
//  RAC_NetRequest_Signal.h
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RACSignal;
@interface RAC_NetRequest_Signal :NSObject

+(RACSignal*)signalWithUrl:(NSString*)url
                parameters:(NSDictionary*)parameters
                      type:(NSInteger)type;
+(NSURLRequest*)JSONPostOperation:(NSString*)url parameters:(NSDictionary*)parameters;
+(NSURLRequest*)JSONGetOperation:(NSString*)url parameters:(NSDictionary*)parameters;
@end
