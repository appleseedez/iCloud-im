//
//  ItelIncomeDataProcesser.h
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelIncomeDataProcesser : NSObject
@property (nonatomic,strong) RACSubject *incomeData;
@property (nonatomic,strong) RACSubject *outSessionInit;
@property (nonatomic,strong) RACSubject *receiveCalling;
@property (nonatomic,strong) RACSubject *receiveAnswering;
@property (nonatomic,strong) RACSubject *loginSuccess;
@property (nonatomic,strong) RACSubject *periodHalt;
@property (nonatomic,strong) RACSubject *droppedFramSignal;
@property (nonatomic,strong) RACSubject *heartBeat;
@property (nonatomic,strong) RACSubject *failSession;
-(void)buildMudel;
@end
