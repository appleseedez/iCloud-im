//
//  SocketConnector.m
//  itelNSC
//
//  Created by nsc on 14-5-26.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "SocketConnector.h"
#import "MaoAppDelegate.h"
#import <objc/runtime.h>
#import "NSData+Byte.h"
//客户端状态值
enum AccountStatusTypes {
    AST_INVALID = -1,
    AST_ONLINE,  // 在线
    AST_OFFLINE, // 离线
    AST_LOGOUT   // 注销
};

//客户端类型值：
enum AccountClientTypes {
    ACT_INVALID = -1,
    ACT_ANDROID, // android客户端
    ACT_IOS,     // IOS客户端
    ACT_WINDOWS, // windows客户端
    ACT_MAC      // mac客户端
};
enum emDataType {
    EDT_INVALID = -1,
    EDT_SIGNEL, // 信令数据
    EDT_MSG     // 消息数据
};
#define HEAD_REQ 0x01111111       // 是数据长度meta包
#define COMMON_PKG_RES 0x01111110 //这表明数据包是一个业务数据
#define ROUTE_SRV_TAG 0x000000fd
#define ROUTE_GATEWAY_TAG 0x000000fe
#define ROUTE_UDP_SEQENCE_END_TAG 0x000000ff
#define kHead @"head"
#define kBody @"body"
#define kType @"type"
#define kStatus @"status"
#define kSeq @"seq"
#define kData @"data"
#define kDataType @"datatype"
#define kAccount @"account"
#define kDomain @"domain"
#define kHostItelNumber @"hostItelNumber"
#define kSrvType @"srvtype"
#define kIP @"ip"
#define kPort @"port"
#define ROUTE_SERVER_IP_REQ_TYPE 0x00000001 // 目录服务器地址请求
#define ROUTE_SERVER_IP_RES_TYPE 0x00010001 // 目录服务器地址请求响应
#define NORMAL_STATUS 0
// 目录服务器请求字段
#define UDP_INDEX_ROUTE_SERVER_TYPE @0
#define UDP_INDEX_GATEWAY_SERVER_TYPE @1
#define CMID_APP_LOGIN_SSS_REQ_TYPE 0x00000002 // app客户端登录业务服务器请求
#define CMID_APP_LOGIN_SSS_RESP_TYPE 0x00010002 // app客户端登录业务服务器应答
@interface SocketConnector  ()
@property (nonatomic) GCDAsyncSocket *tcpSocket; //tcp长连接
@property (nonatomic) dispatch_queue_t socketQueue;
@property (nonatomic) RACSubject *socketSignal;
@property (nonatomic) GCDAsyncUdpSocket *udpSocket;
@end
@implementation SocketConnector
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.socketQueue=dispatch_queue_create("socketQ", NULL);
        self.tcpSocket=[[GCDAsyncSocket alloc]initWithSocketQueue:self.socketQueue];
        [self.tcpSocket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return self;
}
static long udpTag;
static NSUInteger seq;
-(void)getSignalIP{
    if (self.signalServerIP) {
        return;
    }
    MaoAppDelegate *delegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
    self.account=[delegate.loginInfo objectForKey:@"itel"];
    if (!self.account) {
        NSLog(@"没有登录账号");
    }
    self.ip=[delegate.loginInfo objectForKey:@"domain"];
    self.port=[[delegate.loginInfo objectForKey:@"port"] unsignedShortValue];
    self.udpSocket=[[GCDAsyncUdpSocket alloc]initWithSocketQueue:self.socketQueue];
    [self.udpSocket setDelegate:self delegateQueue:dispatch_get_main_queue()];
    if (![self.udpSocket bindToPort:0 error:nil]) {
        [self.udpSocket close];
        self.udpSocket.delegate=nil;
        self.udpSocket=nil;
        [self getSignalIP];
    }
    [self.udpSocket pauseReceiving];
    [self.udpSocket beginReceiving:nil];
    udpTag=ROUTE_SRV_TAG;
    NSDictionary *data=@{
                         kHead:@{
                                 kType:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                                 kSeq: [NSNumber numberWithInteger: ++seq],
                                 
                                 kStatus:[NSNumber numberWithInteger:NORMAL_STATUS]
                                 },
                         kBody:@{
                                 kAccount:self.account,
                                 kSrvType:UDP_INDEX_ROUTE_SERVER_TYPE
                                 }
                         };
    [self udpSend:data];
    
}
-(NSUInteger)seq{
    return ++seq;
}
-(void)udpSend:(NSDictionary *)data{
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];

    [self.udpSocket sendData:jsonData toHost:self.ip port:self.port withTimeout:-1 tag:udpTag];
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (tag == ROUTE_SRV_TAG) {
        udpTag=ROUTE_GATEWAY_TAG;
    }else if(tag == ROUTE_GATEWAY_TAG){
        udpTag = ROUTE_UDP_SEQENCE_END_TAG;
    }
    else{
        udpTag = ROUTE_UDP_SEQENCE_END_TAG;
    }
}
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext{
    NSString* responseString = [NSString stringWithUTF8String:(const char*) [data bytes]];
    NSError* error = nil;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    self.ip = [[response valueForKey:kBody] valueForKey:kIP];
    self.port = [[[response valueForKey:kBody] valueForKey:kPort] intValue];
    if (udpTag == ROUTE_GATEWAY_TAG) {
        [self udpSend:@{
                     kHead:@{
                             kType:[NSNumber numberWithInt:ROUTE_SERVER_IP_REQ_TYPE ],
                             kSeq: [NSNumber numberWithInteger: ++seq],
                             kStatus:[NSNumber numberWithInteger:NORMAL_STATUS]
                             },
                     kBody:@{
                             kAccount:self.account,
                             kSrvType:UDP_INDEX_GATEWAY_SERVER_TYPE
                             }
                     }];
    }else if (udpTag == ROUTE_UDP_SEQENCE_END_TAG){

       
        self.signalServerPort=[[response valueForKeyPath:@"body.port"] unsignedShortValue];
        self.signalServerIP=[response valueForKeyPath:@"body.ip"];
       
        
        NSLog(@"信令服务器获取成功  ip:%@  port:%d",self.signalServerIP,self.signalServerPort);
        [self.udpSocket close];
    }
    
    
    
}

-(void)connect{
    if ([self.conected boolValue]) {
        return;
    }
    
    NSError *error=nil;
    if (![self.tcpSocket connectToHost:self.signalServerIP onPort:self.signalServerPort error:&error]) {
        self.conected=@(NO);
        NSLog(@"连接 tcp 信令服务器没有成功");
        //[self.socketSignal sendError:error];
        
    }
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"连接成功");
    [sock performBlock:^{ [sock enableBackgroundingOnSocket]; }];
     [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_REQ];
    NSString *token = @""; // 推送用到的token
   NSDictionary *info=
    @{
      kHead:@{
              kType: [NSNumber numberWithInt:CMID_APP_LOGIN_SSS_REQ_TYPE],
              kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
              kSeq:[NSNumber numberWithInteger:++seq]
              },
      kBody:@{@"account":self.account,
              @"clienttype":[NSNumber numberWithInt:ACT_IOS],
              @"clientstatus":[NSNumber numberWithInt:AST_ONLINE],
              @"token":token
              }
      
      };
    NSInteger type = [[[info valueForKey:kHead] valueForKey:kType] integerValue];
    [self sendRequest:info type:type];
    self.socketSignal=[RACSubject subject];
    [self.service connectSuccess:self.socketSignal];
    self.conected=@(YES);
    [sock performBlock:^{
        [sock enableBackgroundingOnSocket];
    }];
}
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"发送成功:");
}
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{
    NSLog(@"readStream关闭");
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSError *error;
    switch (tag) {
        case HEAD_REQ: {
            if (sizeof(uint16_t) == [data length]) {
                //解析出包体长度字段.
                uint16_t pkgLength = 0;
                [data getBytes:&pkgLength length:sizeof(uint16_t)];
                // 服务器在长度字段中写入多少.我就读多少出来.
                // 然后交给[NSString stringWithUTF8String:(const char*)[data
                // bytes]]方法转换成json格式字符串.
                // 再转换为NSDictionary. 因为stringWithUTF8String:
                // 方法能够自动去掉结尾的结束符.
                pkgLength = ntohs(pkgLength);
                if (pkgLength < 0) {
                    pkgLength = 0;
                }
                /*现在只需要指名需要读多少长. */
                [sock readDataToLength:pkgLength withTimeout:-1 tag:COMMON_PKG_RES];
            }
            break;
        }
        case COMMON_PKG_RES: {
            //让socket读取队列中始终有一个等候读的
            [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_REQ];
            
            /* parse the response. we need to know the type for delegate method
             * invoking. and status for success or failed */
            /* 和服务器约定, 返回的数据都是UTF8编码后的.
             * 所以在此处只需要将获取的数据转换成utf8字符串. 然后再转换为json*/
            /* 补充: 此处不能直接使用data进行json转换的原因是数据在末尾添加了结束符*/
            NSString *responseString =
            [NSString stringWithUTF8String:(const char *)[data bytes]];
            NSDictionary *response =
            [NSJSONSerialization JSONObjectWithData:
             [responseString dataUsingEncoding:NSUTF8StringEncoding]
                                            options:NSJSONReadingMutableContainers
                                              error:&error];
            if (error) {
                [NSException exceptionWithName:@"500:data serialization error."
                                        reason:@"收到的数据包格式错误"
                                      userInfo:nil];
            }
            [self.socketSignal sendNext:response];
            break;
        }
            
        default:
            break;
    }

}
-(void)disconnect{
    [self.tcpSocket disconnect];
    self.conected=@(NO);
}
-(RACSignal*)socketDataSignal{
    return self.socketSignal;
}
- (void)sendRequest:(NSDictionary *)request type:(NSInteger)type {
    /*构造发送到信令服务器的数据包*/
    NSError *error;
    // 将NSDictionary 序列化为JSON数据.
    NSData *jsonData =
    [NSJSONSerialization dataWithJSONObject:request options:0 error:&error];
    if (error) {
        [NSException exceptionWithName:@"400:data serialzation error"
                                reason:@"数据序列化出错鸟"
                              userInfo:nil];
    }
    
    /*
     在所有请求头部都必须包含2个字节的包长度数据.
     we need to prepend the length of the request in bytes.This is protocol with
     server.
     all the exchange data between client and server should have the package
     length ahead.
     */
    uint16_t pkgLength = (uint16_t)[jsonData length]; // calculate the length of
    // the data package in
    // bytes.
    pkgLength++; // we need to append a '\0' to the package.so that need count in.
    pkgLength = htons(pkgLength); // big end/small end transform.
    /* append the '\0' */
    NSMutableData *requestData = [NSMutableData data];
    //    [requestData appendShort:pkgLength];
    [requestData
     appendData:[NSData dataWithBytes:&pkgLength length:sizeof(uint16_t)]];
    [requestData appendData:jsonData];
    [requestData appendByte:'\0'];    // 5data\0
    /* send data to server.*/
    [self.tcpSocket writeData:[requestData copy] withTimeout:-1 tag:type];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    NSLog(@"socket已经断开连接");
    self.conected=@(NO);
    [self.socketSignal sendCompleted];
    
}
@end
