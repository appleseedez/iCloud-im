//
//  AddressUser.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ItelUser;
@interface AddressUser : NSObject
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *name;
@property (nonatomic) ItelUser *user;
@end
