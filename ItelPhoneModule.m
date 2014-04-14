//
//  ItelPhoneModule.m
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelPhoneModule.h"
#import "ItelSocketConnector.h"
#import "IMSeqenceGen.h"
#import "ItelAction.h"
#import "ItelIncomeDataProcesser.h"
#import "IMSessionInitMessageBuilder.h"
#import "NSCAppDelegate.h"
#import "ItelEngineModule.h"
#import "IMSessionPeriodRequestMessageBuilder.h"
#import "ItelQueryIPModule.h"
@implementation ItelPhoneModule
+(ItelPhoneModule*)getPhoneModule{
    return ((NSCAppDelegate*)[UIApplication sharedApplication].delegate).phoneModule;
}
-(void)buildModule{
    self.queryIP=[RACSubject subject];
    [self buildInternal];
    self.isVideo = [RACSubject subject];
    
    [self.inConnect subscribeNext:^(id x) {
        
        NSDictionary *params=@{@"account":[[ItelAction action]getHost].itelNum,@"clientstatus":@(0),@"clienttype":@(1),@"token":@""};
        
        NSDictionary *authInfo=@{
                                 kHead:@{
                                         kType: [NSNumber numberWithInt:CMID_APP_LOGIN_SSS_REQ_TYPE],
                                         kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                         kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                                         },
                                 kBody:params
                                 
                                 };
        
        [self.socketConnector.inConnect sendNext:authInfo];
    }];
}
-(void)buildInternal{
    //建立模块连接
       //tcp连接器
    self.socketConnector =[[ItelSocketConnector alloc]init];
    [self.socketConnector buildModule];
       //tcp返回数据处理器
    self.incomeDataProcesser=[[ItelIncomeDataProcesser alloc]init];
     self.incomeDataProcesser.incomeData=self.socketConnector.inData;
    [self.incomeDataProcesser buildMudel];
    self.queryIPModule=[[ItelQueryIPModule alloc]init];
    [self.queryIPModule buildModule];
    //引擎模块
    self.EnginModule =[[ItelEngineModule alloc]init];
    [self.EnginModule buildModule];
    self.queryIPModule.outKeepAlive=self.EnginModule.keepAlive;
     //打电话接口
    [self buildCall];
    [self buildReceiveAnswer];
    [self buildInitSession];
    [self buildQueryIp];
    self.inConnect=[RACSubject subject];
    
}
-(void)buildCall{
    self.outCall=[RACSubject subject];
     [self.outCall subscribeNext:^(NSString *destAccount) {
         NSDictionary *data=[[[IMSessionInitMessageBuilder alloc]init]buildWithParams:@{kDestAccount : destAccount }];
         [self.EnginModule.isVideo sendNext:@(1)];
        [self.socketConnector.outData sendNext:data];
    }];

}
-(void)buildInitSession{
     [self.incomeDataProcesser.outSessionInit subscribeNext:^(NSDictionary *data) {
        [self.EnginModule.iniNet sendNext:@(1)];
         [self.EnginModule.iniNet sendNext:data];
              [self.queryIP sendNext:data];
         
        
     }];
    [self.EnginModule.iniNetFinish subscribeNext:^(id x) {
        [[self.EnginModule iniMedia] sendNext:@(1)];
    }];
    
}
-(void)buildReceiveAnswer{
    [self.incomeDataProcesser.receiveAnswering subscribeNext:^(NSDictionary *dic) {
        [self.EnginModule.isVideo sendNext:@([[dic valueForKey:kUseVideo] boolValue])];
        
        [self.EnginModule.inP2P sendNext:dic];
       
    }];
    
}

-(void)buildQueryIp{
    
    
    
    [self.queryIP subscribeNext:^(NSDictionary *userInfo) {
        [self.EnginModule.iniNet sendNext:@(1)];
        NSMutableDictionary *state=[[NSMutableDictionary alloc]init];
        [state setObject:@(YES) forKey:kUseVideo];
        [state setValue:[userInfo valueForKey:kDestAccount]
                 forKey:kPeerAccount];
        // myAccount
        [state setValue:[[ItelAction action]getHost].itelNum forKey:kMyAccount];
        // mySSID
        [state setValue:[userInfo valueForKey:kSessionID] forKey:kMySSID];
        // peerSSID
        [state setValue:
         [NSNumber
          numberWithInteger:
          [[userInfo valueForKey:kSessionID] integerValue] + 1]
                 forKey:kPeerSSID];
        // 转发ip
        [state setValue:[userInfo valueForKey:kRelayIP]
                 forKey:kForwardIP];
        // 转发port
        [state setValue:[userInfo valueForKey:kRelayPort]
                 forKey:kForwardPort];
        // 外网第一次ip探测时的bakport
        [state setValue:[userInfo valueForKey:kBakPort] forKey:kBakPort];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:PEER_FOUND_NOTIFICATION
         object:nil
         userInfo:nil];
        
        NSDictionary *communicationAddress = [self.EnginModule
                                              endPointAddressWithProbeServer:[state valueForKey:kForwardIP]
                                              port:
                                              [[state
                                                valueForKey:kForwardPort] integerValue]
                                              bakPort:[[state
               
                                                        valueForKey:kBakPort] integerValue]];
        [self.queryIPModule.inStart sendNext:state];
        // 6. 把数据组装准备发送.
        //此处我需要做的是字典的数据融合！！！
        NSMutableDictionary *mergeData = [communicationAddress mutableCopy];
        
        //将信令服务器返回的通话查询请求的响应中的转发地址和目的号码取出来，合并进新的通话请求信令中
        //总是在传递是以接收方的角度去思
        //由于信令是发给对方的。所以destAccount和srcaccount应该是从对方的角度去思考。因此destAccount填的是自己的帐号，srcaccount填写的是对方的帐号。这样，在对方看来就是完美的。而且，对等方在构造信令数据时有相同的逻辑考
       
        [mergeData addEntriesFromDictionary:
         @{
           kType : [NSNumber numberWithInt:SESSION_PERIOD_CALLING_TYPE],
           kRelayIP : [state valueForKey:kForwardIP],
           kRelayPort : [state valueForKey:kForwardPort],
           kSrcSSID : [state valueForKey:kPeerSSID],
           kDestSSID : [state valueForKey:kMySSID],
           kDestAccount : [[ItelAction action]getHost].itelNum,
           kSrcAccount : [state valueForKey:kPeerAccount],
           kPeerNATType :
               @([ItelEngineModule getNatType]),
           kUseVideo : [state valueForKey:kUseVideo],
           kBakPort : [state valueForKey:kBakPort]
           }];
        
        // 构造通话数据请求
        IMSessionPeriodRequestMessageBuilder *messageBuilder= [[IMSessionPeriodRequestMessageBuilder alloc] init];
        NSDictionary *data = [messageBuilder buildWithParams:mergeData];
        
        // 8. 发送通信所需的数据
        [self.socketConnector.outData sendNext:data];
        
    }];

}

@end
