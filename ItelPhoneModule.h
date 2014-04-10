//
//  ItelPhoneModule.h
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ItelSocketConnector;
@class ItelIncomeDataProcesser;
@interface ItelPhoneModule : NSObject
@property (nonatomic) ItelSocketConnector *socketConnector;
@property (nonatomic) ItelIncomeDataProcesser *incomeDataProcesser;
@property  (nonatomic) RACSubject *inConnect;
@property  (nonatomic) RACSubject *outCall;
+(ItelPhoneModule*)getPhoneModule;
-(void)buildModule;
@end
