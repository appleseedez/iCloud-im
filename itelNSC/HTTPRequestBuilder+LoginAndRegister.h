//
//  HTTPRequestBuilder+LoginAndRegister.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-7.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder.h"

@interface HTTPRequestBuilder (LoginAndRegister)
-(RACSignal*)login:(NSString*)itel password:(NSString*)password;
-(RACSignal*)regCheckItel:(NSDictionary*)parameters;
-(RACSignal*)regSendMessage:(NSDictionary*)parameters;
-(RACSignal*)regCheckMesCode:(NSDictionary*)parameters;
-(RACSignal*)regGetRandomNumbers;
-(RACSignal*)passGetToken;
-(RACSignal*)passSendMessage:(NSDictionary*)parameters;
-(RACSignal*)passGetCodeImage:(NSString*)token;
-(RACSignal*)passCheckToken:(NSDictionary*)parameters;
-(RACSignal*)passCheckPhoneCode:(NSDictionary*)parameters;
-(RACSignal*)passSendNewPassword:(NSDictionary*)parameters;
-(RACSignal*)passAnswerQuestion:(NSDictionary*)parameters;
-(RACSignal*)passSendEmail:(NSDictionary*)parameters;
-(RACSignal*)passCheckEmailCode:(NSDictionary*)parameters;
@end
