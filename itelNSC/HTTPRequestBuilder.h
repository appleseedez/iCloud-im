//
//  HTTPRequestBuilder.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MaoAppDelegate;
@interface HTTPRequestBuilder : NSObject

@property (nonatomic) NSString *UUID;
@property (nonatomic,weak) MaoAppDelegate *delegate;
+(HTTPRequestBuilder*)defaultBuilder;
-(NSURLRequest*)jsonPostRequestWithUrl:(NSString*)url
                         andParameters:(NSDictionary*)parameters;
-(NSURLRequest*)getRequestWithUrl:(NSString*)url andParameters:(NSDictionary*)parameters;
@end
