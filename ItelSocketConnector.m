//
//  ItelSocketConnector.m
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelSocketConnector.h"
#import "GCDAsyncSocket.h"
@implementation ItelSocketConnector

-(void)buildModule{
    self.signalIP=@"115.29.145.142";
    self.signalPort=9989;
    self.inData=[RACSubject subject];
    self.outData=[RACSubject subject];
    self.inConnect=[RACSubject subject];
    self.outDidConnected=[RACSubject subject];
    self.inDidDisConnected=[RACSubject subject];
    [self socket];
    //连接
    RACSignal *connectSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:self.inConnect];
        
        return nil;
    }]flatten];
    [connectSignal subscribeNext:^(NSDictionary *parameters) {
        if (![self.socket isConnected]) {
            NSError *error;
            if (![self.socket connectToHost:self.signalIP onPort:self.signalPort error:&error]) {
                NSLog(@"%@",error);
            }
            self.authInfo=parameters;
        }
    }];
    //发送
    RACSignal *sendSignal=[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:self.outData];
        return nil;
    }]flatten] map:^id(NSDictionary *request) {
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
        [requestData appendByte:'\0'];
        // 5data\0
        /* send data to server.*/
        return requestData;
    }];
      [sendSignal subscribeNext:^(NSData *requestData) {
                    [self.socket writeData:[requestData copy] withTimeout:-1 tag:0];

      }];
    
    
}

-(GCDAsyncSocket*)socket{
    if (_socket==nil) {
        
        
    dispatch_queue_t socketQ=dispatch_queue_create("socketQueue", NULL);
        
        
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                           delegateQueue:socketQ];
    }
    return _socket;
}
- (void)socket:(GCDAsyncSocket *)sock
   didReadData:(NSData *)data
       withTag:(long)tag{
    
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
            NSLog(@"收到啦：descriptipn:%@",[[response valueForKey:@"body"] valueForKey:@"description"]);
            [self.inData sendNext:response];
            break;
        }
            
        default:
            break;
    }

    
    
}
- (void)socket:(GCDAsyncSocket *)sock
didConnectToHost:(NSString *)host
          port:(uint16_t)port{
    [sock performBlock:^{ [sock enableBackgroundingOnSocket]; }];
    [sock readDataToLength:sizeof(uint16_t) withTimeout:-1 tag:HEAD_REQ];
    NSLog(@"tcp 连接建立完成.准备发送认证信息到信令服务器");
    [self.outData sendNext:self.authInfo];
    

    
}
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [self.inDidDisConnected sendNext:@(1)];
}
@end
