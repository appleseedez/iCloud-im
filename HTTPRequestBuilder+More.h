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
@end
