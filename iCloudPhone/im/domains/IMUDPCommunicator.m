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

@end

@implementation IMUDPCommunicator
- (id)init{
    if (self=[super init]) {
        _udpSock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _tag = ROUTE_UDP_SEQENCE_END_TAG;
    }
    return self;
}
- (void)connect:(NSString*) account{
    
	NSError *error = nil;
	
	if (![self.udpSock bindToPort:0 error:&error])
	{
        [NSException exceptionWithName:@"upd binding error" reason:@"upd绑定端口失败了" userInfo:nil];
		return;
	}
	if (![self.udpSock beginReceiving:&error])
	{
        [NSException exceptionWithName:@"beginReceving error" reason:@"upd绑定端口失败了" userInfo:nil];
		return;
	}
    //从登陆服务器获取
    self.account = account;
    if (!self.account) {
        [NSException exceptionWithName:@"account is nil" reason:@"账号为空" userInfo:nil];
    }
//    self.ip = ROUTE_SERVER_IP;
//    self.port = ROUTE_SERVER_PORT;
    self.tag = ROUTE_SRV_TAG;
    NSLog(@"udpConnector.ip:%@",self.ip);
    [self send:@{
                 HEAD_SECTION_KEY:@{
                         DATA_TYPE_KEY:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                         DATA_SEQ_KEY: [NSNumber numberWithInteger: [[IMSeqenceGen class] seq]],
                         
                         DATA_STATUS_KEY:[NSNumber numberWithInteger:NORMAL_STATUS]
                         },
                 BODY_SECTION_KEY:@{
                         UDP_INDEX_REQ_FIELD_ACCOUNT_KEY:self.account,
                         UDP_INDEX_REQ_FIELD_SRVTYPE_KEY:UDP_INDEX_ROUTE_SERVER_TYPE
                         }
                 }];
    
//    [self.udpSock connectToHost:ROUTE_SERVER_IP onPort:ROUTE_SERVER_PORT error:&error];
//    if (error) {
//        NSLog(@"链接服务器的异常:%@",error);
//    }

	
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
  
    self.ip = [[response valueForKey:BODY_SECTION_KEY] valueForKey:UDP_INDEX_RES_FIELD_SERVER_IP_KEY];
    self.port = [[[response valueForKey:BODY_SECTION_KEY] valueForKey:UDP_INDEX_RES_FIELD_SERVER_PORT_KEY] intValue];
    if (self.tag == ROUTE_GATEWAY_TAG) {
        [self send:@{
                     HEAD_SECTION_KEY:@{
                             DATA_TYPE_KEY:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                             DATA_SEQ_KEY: [NSNumber numberWithInteger: [[IMSeqenceGen class] seq]],
                             DATA_STATUS_KEY:[NSNumber numberWithInteger:NORMAL_STATUS]
                             },
                     BODY_SECTION_KEY:@{
                             UDP_INDEX_REQ_FIELD_ACCOUNT_KEY:self.account,
                             UDP_INDEX_REQ_FIELD_SRVTYPE_KEY:UDP_INDEX_GATEWAY_SERVER_TYPE
                             }
                     }];
    }else if (self.tag == ROUTE_UDP_SEQENCE_END_TAG){
//         NSLog(@"最后拿到的ip:%@,port:%d",self.ip,self.port);
//        [[response valueForKey:BODY_SECTION_KEY] setValue:@"10.0.0.30" forKey:UDP_INDEX_RES_FIELD_SERVER_IP_KEY];
#if UDP_MESSAGE
        NSLog(@"最后登录的业务服务器：%@",response);
#endif
        [self receive:response];
    }
    
    
    
}
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error{
    
}
@end
