//
//  HTTPRequestBuilder+contact.h
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "HTTPRequestBuilder.h"

@interface HTTPRequestBuilder (contact)
-(RACSignal*)addNewFriend:(NSDictionary*)parameters;
-(RACSignal*)getFriendList:(NSDictionary*)parameters;
-(RACSignal*)editUserAlias:(NSDictionary*)parameters;
-(RACSignal*)delFriend:(NSDictionary*)parameters;
-(RACSignal*)addToBlack:(NSDictionary*)parameters;
-(RACSignal*)searchStranger:(NSDictionary*)parameters;
@end
