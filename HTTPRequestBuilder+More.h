//
//  HTTPRequestBuilder+More.h
//  itelNSC
//
//  Created by nsc on 14-5-15.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder.h"

@interface HTTPRequestBuilder (More)
-(RACSignal*)modifyHost:(NSDictionary*)parameters;
-(RACSignal*)checkPhoneNumber:(NSDictionary*)parameters;
-(RACSignal*)moreSendMessager:(NSDictionary*)parameters;
-(RACSignal*)checkCodeNumber:(NSDictionary*)parameters;
-(RACSignal*)loadBlackList:(NSDictionary*)parameters;
-(RACSignal*)removeFromBlackList:(NSDictionary*)parameters;
-(RACSignal*)changePassword:(NSDictionary*)parameters;
-(RACSignal*)getUserSecurity:(NSDictionary*)parameters;
-(RACSignal*)checkUserAnswer:(NSDictionary*)parameters;
-(RACSignal*)modifyProtection:(NSDictionary*)parameters;
@end
