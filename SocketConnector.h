//
//  SocketConnector.h
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "IMService.h"
@interface SocketConnector : NSObject  <GCDAsyncSocketDelegate,GCDAsyncUdpSocketDelegate>

@property (nonatomic,copy) NSString *ip;
@property (nonatomic) uint16_t port;
@property (nonatomic) NSString *account;
@property (nonatomic) NSString *signalServerIP;
@property (nonatomic) uint16_t signalServerPort;
@property (nonatomic) NSNumber *conected; //bool 是否连接

@property (nonatomic) IMService *service;
-(void)connect;
-(RACSignal*)socketDataSignal;
-(void)getSignalIP;
-(NSUInteger)seq;
- (void)sendRequest:(NSDictionary *)request type:(NSInteger)type;
@end
