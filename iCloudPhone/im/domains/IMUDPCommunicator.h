//
//  IMUDPCommunicator.h
//  iCloudPhone
//
//  Created by Pharaoh on 13-12-16.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCommunicator.h"
#import "ConstantHeader.h"
#import "GCDAsyncUdpSocket.h"
@interface IMUDPCommunicator : NSObject<IMCommunicator>
@property(nonatomic) long tag;
@property(nonatomic,copy) NSString* ip;
@property(nonatomic) uint16_t port;
@property(nonatomic,copy) NSString* account;
@end
