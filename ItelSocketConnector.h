//
//  ItelSocketConnector.h
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GCDAsyncSocket;
@protocol GCDAsyncSocketDelegate;

@interface ItelSocketConnector : NSObject <GCDAsyncSocketDelegate>
-(void)buildModule;
@property (nonatomic,strong) RACSubject *inData;
@property (nonatomic,strong) RACSubject *outData;
@property (nonatomic,strong) RACSubject *outDidConnected;
@property (nonatomic,strong) RACSubject *inConnect;
@property (nonatomic,strong) RACSubject *inDidDisConnected;
@property (nonatomic,strong) GCDAsyncSocket *socket;
@property (nonatomic,copy) NSString *signalIP;
@property (nonatomic)      uint16_t  signalPort;
@property (nonatomic,strong) NSDictionary *authInfo;
@end
