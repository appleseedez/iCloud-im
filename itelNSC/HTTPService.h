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
@end
