//
//  IMTCPCommunicator.h
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMCommunicator.h"
#import "GCDAsyncSocket.h"
@interface IMTCPCommunicator : NSObject <IMCommunicator>
@property(nonatomic,copy) NSString* ip;
@property(nonatomic) uint16_t port;
@property(nonatomic,copy) NSString* account;
@end
