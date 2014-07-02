//
//  HTTPRequestBuilder+app.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder.h"

@interface HTTPRequestBuilder (app)
-(RACSignal*)logout:(NSDictionary*)parameters;
-(RACSignal*)subPushToken:(NSDictionary*)parameters;
@end
