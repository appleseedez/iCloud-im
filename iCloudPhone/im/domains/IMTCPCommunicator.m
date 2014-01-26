//
//  IMTCPCommunicator.m
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMTCPCommunicator.h"
#import "ConstantHeader.h"
@interface IMTCPCommunicator ()<GCDAsyncSocketDelegate>
@property(nonatomic) GCDAsyncSocket* sock; // tcp长链接端点
@property(nonatomic) MSWeakTimer* heartBeat; // 心跳定时器
@property(nonatomic) NSDictionary* heartBeatPKG; // 心跳包
@property(nonatomic) NSDictionary* authInfo; //登录信息
@end

@implementation IMTCPCommunicator
- (id)init{
    if (self = [super init]) {
        _sock = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
//        _ip = SIGNAL_SERVER_IP;
//        _port=SIGNAL_SERVER_PORT;
        //心跳包是固定的格式，可以直接构造。
        _heartBeatPKG = @{
                          @"head":@{
                                  @"type": [NSNumber numberWithInt:HEART_BEAT_REQ_TYPE],
                                  @"status":[NSNumber numberWithInt:NORMAL_STATUS],
                                  @"seq":[NSNumber numberWithInt:SEQ_BASE]
                                  },
                          @"body":@{}
                          };
        
    }
    return self;
}

- (void) sendHeartBeat{
    if ([self.sock isConnected]) {
        NSLog(@"咚咚");
        [self sendRequest:self.heartBeatPKG type:HEART_BEAT_REQ_TYPE];
    }
}

//发送数据包到信令服务器
- (void) sendRequest:(NSDictionary*) request type:(NSInteger) type{
    /*构造发送到信令服务器的数据包*/
    NSError* error;
    // 将NSDictionary 序列化为JSON数据.
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:request options:0 error:&error];
    if (error) {
        [NSException exceptionWithName:@"400:data serialzation error" reason:@"数据序列化出错鸟" userInfo:nil];
    }
    
    /*
     在所有请求头部都必须包含2个字节的包长度数据.
     we need to prepend the length of the request in bytes.This is protocol with server.
     all the exchange data between client and server should have the package length ahead.
     */
    uint16_t pkgLength = (uint16_t)[jsonData length];// calculate the length of the data package in bytes.
    pkgLength++; // we need to append a '\0' to the package.so that need count in.
    pkgLength = htons(pkgLength);// big end/small end transform.
    /* append the '\0' */
    NSMutableData* requestData = [NSMutableData data];
    //    [requestData appendShort:pkgLength];
    [requestData appendData:[NSData dataWithBytes:&pkgLength length:sizeof(uint16_t)]];
    [requestData appendData:jsonData];
    [requestData appendByte:'\0'];
    // 5data\0
    /* send data to server.*/
    [self.sock writeData:[requestData copy] withTimeout:-1 tag:type];
    
}
#pragma mark - INTERFACE
// GCDAysncSocket 接口
// 链接上了服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
#if usertip
    [[IMTipImp defaultTip] showTip:@"连接上了信令服务器"];
#endif
    [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_REQ];
    [self send:self.authInfo];
}
// 断开了服务器链接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:RECONNECT_TO_SIGNAL_SERVER_NOTIFICATION object:nil userInfo:nil];
    });
}

// 有数据来。我们的数据是分成两部分的 :
// head_pkg | data_pkg
// 先读head_pkg 其长度是固定的sizeof(uint16_t)。从中可以知道data_pkg的大小。这样设计是为了防止tcp粘包问题
// 原理参考《TCP/IP高效编程》（Effective TCP/IP Programing) 技巧6:记住，TCP是流协议
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSError* error;
    switch (tag) {
        case HEAD_REQ:
        {
            if (sizeof(uint16_t) == [data length]) {
                //解析出包体长度字段.
                uint16_t pkgLength = 0;
                [data getBytes:&pkgLength length:sizeof(uint16_t)];
                // 服务器在长度字段中写入多少.我就读多少出来.
                // 然后交给[NSString stringWithUTF8String:(const char*)[data bytes]]方法转换成json格式字符串.
                // 再转换为NSDictionary. 因为stringWithUTF8String: 方法能够自动去掉结尾的结束符.
                pkgLength = ntohs(pkgLength);
                if (pkgLength<0) {
                    pkgLength = 0;
                }
                /*现在只需要指名需要读多少长. */
                [sock readDataToLength:pkgLength withTimeout:-1 tag:COMMON_PKG_RES];
                
            }
            break;
        }
        case COMMON_PKG_RES:
        {
            //让socket读取队列中始终有一个等候读的
            [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_REQ];
            
            /* parse the response. we need to know the type for delegate method invoking. and status for success or failed */
            /* 和服务器约定, 返回的数据都是UTF8编码后的. 所以在此处只需要将获取的数据转换成utf8字符串. 然后再转换为json*/
            /* 补充: 此处不能直接使用data进行json转换的原因是数据在末尾添加了结束符*/
            NSString* responseString = [NSString stringWithUTF8String:(const char*)[data bytes]];
            NSDictionary* response = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:&error];
            if (error) {
                [NSException exceptionWithName:@"500:data serialization error." reason:@"收到的数据包格式错误" userInfo:nil];
            }
            [self receive:response];
            break;
        }
            
        default:
            break;
    }
}
// IMCommunicator接口
- (void)connect:(NSString*) account withAuthInfo:(NSDictionary *)authInfo{
    NSError* error;
    self.account = account;
    if ([self.sock isConnected]) {
        [self disconnect];
    }
    self.authInfo = authInfo;
    if (![self.sock connectToHost:self.ip onPort:self.port error:&error]) {
#if debug
        [[IMTipImp defaultTip] errorTip:@"链接信令服务器失败"];
#endif
        [self disconnect];
    }

}

- (void)disconnect{
    // 终止心跳
    [self.heartBeat invalidate];
    [self.sock disconnect];
}

- (void)send:(NSDictionary*) data{
    NSInteger type = [[[data valueForKey:HEAD_SECTION_KEY] valueForKey:DATA_TYPE_KEY] integerValue];
    [self sendRequest:data type:type];
}

- (void)receive:(NSDictionary*) data{
    //通知相应的业务，数据来了
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_RECEIVED_NOTIFICATION object:nil userInfo:data];
}

- (void)keepAlive{
    
    [self.heartBeat invalidate];
    self.heartBeat = [MSWeakTimer scheduledTimerWithTimeInterval:HEART_BEAT_INTERVAL target:self selector:@selector(sendHeartBeat) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("com.itelland.private_queue", DISPATCH_QUEUE_CONCURRENT)];
}


- (void)setupIP:(NSString *)ip{
    self.ip = ip;
}
- (void) setupPort:(uint16_t)port{
    self.port = port;
}
- (void)tearDown{
    
}
@end
