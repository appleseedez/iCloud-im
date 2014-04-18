//
//  NetRequestBuilder.h
//  iCloudPhone
//
//  Created by nsc on 14-4-18.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetRequestBuilder : NSObject
+(NSURLRequest*)getRequest:(NSDictionary*)parameters url:(NSString*)url;
+(NSURLRequest*)JSONPostRequset:(NSDictionary*)parameters url:(NSString*)url;
@end
