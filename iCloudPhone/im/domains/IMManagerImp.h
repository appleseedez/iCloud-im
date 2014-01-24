//
//  IMManagerImp.h
//  iCloudPhone
//
//  Created by Pharaoh on 1/23/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import "IMManager.h"
#import "IMEngine.h"
#import "IMEngineImp.h"
#import "IMCommunicator.h"
#import "IMTCPCommunicator.h"
#import "IMUDPCommunicator.h"
#import "IMMessageBuilder.h"
#import "IMSessionInitMessageBuilder.h"
#import "IMAuthMessageBuilder.h"
#import "IMSessionPeriodRequestMessageBuilder.h"
#import "IMSessionPeriodResponseMessageBuilder.h"
#import "IMSessionRefuseMessageBuilder.h"
#import "IMLogoutFromSignalServerMessageBuilder.h"
#import "IMManager.h"
@interface IMManagerImp : NSObject <IMManager,UIAlertViewDelegate>
//引擎
@property (nonatomic) id<IMEngine> engine;
//网络通信器
@property (nonatomic) id<IMCommunicator> TCPcommunicator;

@property (nonatomic) id<IMCommunicator> UDPcommunicator;
// 信令构造器
@property (nonatomic) id<IMMessageBuilder> messageBuilder;

@property(nonatomic,copy) NSString* routeIP;

@property(nonatomic) u_int16_t port;
@end
