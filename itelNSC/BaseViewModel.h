//
//  BaseViewModel.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequestBuilder.h"
#import "HTTPService.h"
@interface BaseViewModel : NSObject
@property (nonatomic,weak) HTTPRequestBuilder *requestBuilder;
@property (nonatomic,weak) HTTPService *httpService;
@property (nonatomic,strong) NSNumber *busy;
-(void)netRequestError:(NSError*)error;
-(void)netRequestFail:(NSDictionary*)data;
-(void)serverError;
@end
