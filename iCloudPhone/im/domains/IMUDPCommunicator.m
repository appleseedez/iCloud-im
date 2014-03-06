//
//  IMUDPCommunicator.m
//  iCloudPhone
//
//  Created by Pharaoh on 13-12-16.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "IMUDPCommunicator.h"
#import "IMSeqenceGen.h"
@interface IMUDPCommunicator()<GCDAsyncUdpSocketDelegate>
{
}
@property(nonatomic) GCDAsyncUdpSocket* udpSock; //udp 链接 用于请求目录服务器
@property(nonatomic) int udpPort;
@end

@implementation IMUDPCommunicator
- (id)init{
    if (self=[super init]) {
        _udpSock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _tag = ROUTE_UDP_SEQENCE_END_TAG;
    }
    return self;
}
static int localUDPNetPortSuffix = 0;
- (void)connect:(NSString*) account{
    NSLog(@"calling %@",NSStringFromSelector(_cmd));
    self.udpPort = LOCAL_UDP_PORT + (++localUDPNetPortSuffix)%9;
	NSError *error = nil;
	
	if (![self.udpSock bindToPort:self.udpPort error:&error])
	{
#if DEBUG
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:NSLocalizedString(@"连接中...", nil)
                                        type:TSMessageNotificationTypeWarning];
//        [[IMTipImp defaultTip] errorTip:@"udp绑定端口失败了"];
#endif
        NSLog(@"bind error:%@",error);
        NSAssert(self.udpSock, @"udpsock is nil");
        [self.udpSock close];
//        [self connect:account];
        [[NSNotificationCenter defaultCenter] postNotificationName:RECONNECT_TO_SIGNAL_SERVER_NOTIFICATION object:nil];
		return;
	}
	if (![self.udpSock beginReceiving:&error])
	{
#if DEBUG
//        [[IMTipImp defaultTip] errorTip:@"udp开始接收数据失败了"];
#endif
		return;
	}
    //从登陆服务器获取
    self.account = account;
    if (!self.account) {
#if usertip
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:NSLocalizedString(@"帐号为空! 无法登录", nil)
                                        type:TSMessageNotificationTypeWarning];
//        [[IMTipImp defaultTip] errorTip:@"帐号为空! 无法登录"];
#endif
        [NSException exceptionWithName:@"account is nil" reason:@"账号为空" userInfo:nil];
    }
//    self.ip = ROUTE_SERVER_IP;
//    self.port = ROUTE_SERVER_PORT;
    self.tag = ROUTE_SRV_TAG;
    NSLog(@"udpConnector.ip:%@",self.ip);
    [self send:@{
                 kHead:@{
                         kType:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                         kSeq: [NSNumber numberWithInteger: [[IMSeqenceGen class] seq]],
                         
                         kStatus:[NSNumber numberWithInteger:NORMAL_STATUS]
                         },
                 kBody:@{
                         kAccount:self.account,
                         kSrvType:UDP_INDEX_ROUTE_SERVER_TYPE
                         }
                 }];
    
}
- (void)disconnect{
}
- (void)send:(NSDictionary *)data{
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
#if UDP_MESSAGE
    NSLog(@"udp 数据,准备发送的:%@ 到 %@:%d",data,self.ip,self.port);
#endif
    [self.udpSock sendData:jsonData toHost:self.ip port:self.port withTimeout:-1 tag:self.tag];
}
- (void)receive:(NSDictionary *)data{
#if UDP_MESSAGE
    NSLog(@"最后收到数据:%@",data);
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:UDP_LOOKUP_COMPLETE_NOTIFICATION object:nil userInfo:data];
}

- (void)setupIP:(NSString *)ip{
    self.ip = ip;
}
- (void) setupPort:(uint16_t)port{
    self.port = port;
}

#pragma mark - delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (tag == ROUTE_SRV_TAG) {
        self.tag=ROUTE_GATEWAY_TAG;
    }else if(tag == ROUTE_GATEWAY_TAG){
        self.tag = ROUTE_UDP_SEQENCE_END_TAG;
    }
    else{
        self.tag = ROUTE_UDP_SEQENCE_END_TAG;
    }
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address{

}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString* responseString = [NSString stringWithUTF8String:(const char*) [data bytes]];
    NSError* error = nil;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
  
    self.ip = [[response valueForKey:kBody] valueForKey:kIP];
    self.port = [[[response valueForKey:kBody] valueForKey:kPort] intValue];
    if (self.tag == ROUTE_GATEWAY_TAG) {
        [self send:@{
                     kHead:@{
                             kType:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                             kSeq: [NSNumber numberWithInteger: [[IMSeqenceGen class] seq]],
                             kStatus:[NSNumber numberWithInteger:NORMAL_STATUS]
                             },
                     kBody:@{
                             kAccount:self.account,
                             kSrvType:UDP_INDEX_GATEWAY_SERVER_TYPE
                             }
                     }];
    }else if (self.tag == ROUTE_UDP_SEQENCE_END_TAG){
#if UDP_MESSAGE
        NSLog(@"最后登录的业务服务器：%@",response);
#endif
        [self.udpSock close];
        [self receive:response];
    }
    
    
    
}
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
}
- (void)tearDown{
    [self.udpSock close];
    localUDPNetPortSuffix = 0;
    self.udpSock.delegate = nil;
    self.udpSock = nil;
}
@end
