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
@class ItelEngineModule;
@class ItelQueryIPModule;
@interface ItelPhoneModule : NSObject
@property (nonatomic) ItelSocketConnector *socketConnector;
@property (nonatomic) ItelIncomeDataProcesser *incomeDataProcesser;
@property (nonatomic) ItelEngineModule *EnginModule;

@property  (nonatomic) RACSubject *inConnect;
@property  (nonatomic) RACSubject *outCall;
@property (nonatomic) RACSubject *isVideo;
@property (nonatomic) RACSubject *queryIP;
@property (nonatomic) ItelQueryIPModule *queryIPModule;
+(ItelPhoneModule*)getPhoneModule;
-(void)buildModule;
@end
