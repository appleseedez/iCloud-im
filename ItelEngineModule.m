//
//  ItelEngineModule.m
//  iCloudPhone
//
//  Created by nsc on 14-4-11.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelEngineModule.h"
#import "NatTypeImpl.h"
#import "AVInterface.h"
#import "ItelAction.h"
@interface ItelEngineModule ()
@property(atomic) CAVInterfaceAPI *pInterfaceApi;
@property(nonatomic) InitType m_type;
@property(nonatomic, copy) NSString *currentInterIP;
@property(nonatomic) int cameraIndex;
@property(nonatomic) BOOL isCameraOpened;
@property(nonatomic) int netWorkPort;
@property(nonatomic) dispatch_queue_t q;
@property(nonatomic) dispatch_queue_t m;
@property(atomic) BOOL p2pFinished;
@property(nonatomic) int selfNATType;
@property(nonatomic, copy) NSString *stunServer;

@end
@implementation ItelEngineModule
-(void)buildModule{
    
    self.keepAlive = [RACSubject subject];
    
    self.cameraIndex = 1;
    self.isCameraOpened = NO;
    self.netWorkPort = LOCAL_PORT;
    self.pInterfaceApi = new CAVInterfaceAPI();
    self.q = dispatch_queue_create(
                                   "com.itelland.p2ptunnelprivatequeue",
                                   NULL); // dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    // //dispatch_queue_create("com.itelland.p2ptunnelprivatequeue",
    // NULL );//
    self.m = dispatch_get_global_queue(
                                       DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                       0); // dispatch_queue_create("com.itelland.stopP2Pprivatequeue", NULL );
    _pview_local = [[UIView alloc]
                    initWithFrame:CGRectMake(0, 0, FULL_SCREEN.size.width * .3,
                                             FULL_SCREEN.size.height * .3)];
    self.p2pFinished = YES;

    
    
    self.inP2P=[RACSubject subject];
    self.isVideo=[RACSubject subject];
    self.pInterfaceApi = new CAVInterfaceAPI();
    RACSignal *P2PSignal=[RACSignal combineLatest:@[self.inP2P,self.isVideo]];
    
     [P2PSignal subscribeNext:^(RACTuple *tuple) {
         BOOL isVideo=[[tuple objectAtIndex:1]boolValue];
         NSDictionary *params=[tuple objectAtIndex:0];
         
         bool __block ret = true;
         TP2PPeerArgc __block argc;
         
         dispatch_async(self.q, ^{
             //
             NSLog(@"开始获取p2p通道,%@", [NSDate date]);
             
             //根据传入的useVideo参数,确定最终穿透以后是走音频还是视频.
             if (isVideo && [[params valueForKey:kUseVideo] boolValue]) {
                 self.m_type = InitTypeVoeAndVie;
             } else {
                 self.m_type = InitTypeVoe;
             }
            // NSLog(@"穿透时使用的类型:%@", [self mediaTypeString:self.m_type]);
             NSLog(@"穿透时使用的NAT类型:%@", [params valueForKey:kPeerNATType]);
             // 外网地址
             ::strncpy(argc.otherInterIP, [[params valueForKey:kPeerInterIP] UTF8String],
                       sizeof(argc.otherInterIP));
             argc.otherInterPort = [[params valueForKey:kPeerPort] intValue];
             // 内网地址
             ::strncpy(argc.otherLocalIP, [[params valueForKey:kPeerLocalIP] UTF8String],
                       sizeof(argc.otherLocalIP));
             argc.otherLocalPort = [[params valueForKey:kPeerLocalPort] intValue];
             // 转发地址
             ::strncpy(argc.otherForwardIP, [[params valueForKey:kRelayIP] UTF8String],
                       sizeof(argc.otherForwardIP));
             argc.otherForwardPort = [[params valueForKey:kRelayPort] intValue];
             
             // 对方的ssid
             argc.otherSsid = [[params valueForKey:kDestSSID] intValue];
             // 自己的ssid
             argc.selfSsid = [[params valueForKey:kSrcSSID] intValue];
             
             argc.otherNATType = [[params valueForKey:kPeerNATType] intValue];
             argc.selfNATType = self.selfNATType;
             //如果内网的ip相同.设置argc.localable = true;
             
             if ([self.currentInterIP
                  isEqualToString:
                  [NSString stringWithUTF8String:argc.otherInterIP]] ||
                 [self.currentInterIP isEqualToString:BLANK_STRING] ||
                 [[NSString stringWithUTF8String:argc.otherInterIP]
                  isEqualToString:BLANK_STRING]) {
                     argc.localEnble = true;
                 } else {
                     argc.localEnble = false;
                 }
             
             NSLog(@"本机的外网ip：%@", self.currentInterIP);
             NSLog(@"对方的外网ip：%@",
                   [NSString stringWithUTF8String:argc.otherInterIP]);
             NSLog(@"设置localable为：%d", argc.localEnble);
             NSLog(@"通话参数：对方外网ip：%s", argc.otherInterIP);
             NSLog(@"通话参数：对方外网port：%i", argc.otherInterPort);
             NSLog(@"通话参数：对方内网ip：%s", argc.otherLocalIP);
             NSLog(@"通话参数：对方内网port:%i", argc.otherLocalPort);
             NSLog(@"通话参数：对方ssid：%i", argc.otherSsid);
             NSLog(@"通话参数：自己ssid：%i", argc.selfSsid);
             NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
             //        NSAssert(_pInterfaceApi != nil, @"pInterface is nilA");
             self.p2pFinished = NO;
             if (_pInterfaceApi && _pInterfaceApi->GetP2PPeer(argc) != 0) {
                 //            return -1;
                 ret = false;
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 //#if DEBUG
                 //            [[IMTipImp defaultTip] showTip:@"<<<<<<p2p结束>>>>>>>"];
                 //#endif
                 self.p2pFinished = YES;
                 NSLog(@"媒体类型:%d", self.m_type);
                 NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
                 long long dTime = endTime - startTime;
                 NSLog(@"调用时间间隔：%@", [NSString stringWithFormat:@"%llu", dTime]);
                 //如果p2p失败, 立即通知
                 if (ret == false) {
                     NSLog(@"execute here5");
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:P2PTUNNEL_FAILED
                      object:nil
                      userInfo:params];
                     return;
                 }
                 NSLog(@"isLocal的状态：%d", argc.islocal);
                 //#if DEBUG
                 //            [[IMTipImp defaultTip] showTip:@"准备startmedia"];
                 //#endif
                 
                 TVideoConfigInfo vieConfig;
                 //            if (iPhone5) {
                 //                vieConfig.height = 192;
                 //            }else{
                 //                vieConfig.height = 176;
                 //            }
                 vieConfig.height = 176;
                 vieConfig.width = 144;
                 vieConfig.maxFramerate = 15;
                 vieConfig.startBitrate = 80;
                 vieConfig.maxBitrate = 600;
                 if (argc.islocal) {
                     NSLog(@"内网可用[%s:%d]", argc.otherLocalIP, argc.otherLocalPort);
                     if (isVideo) {
                         ret = self.pInterfaceApi->StartVieMedia(argc.otherLocalIP,
                                                                 argc.otherLocalPort,
                                                                 vieConfig); // 要判断返回值
                     } else {
                         ret = self.pInterfaceApi->StartVoeMedia(argc.otherLocalIP,
                                                                 argc.otherLocalPort);
                     }
                 } else if (argc.isInter) {
                     NSLog(@"外网可用[%s:%d]", argc.otherInterIP, argc.otherInterPort);
                     if (isVideo) {
                         ret = self.pInterfaceApi->StartVieMedia(argc.otherInterIP,
                                                                 argc.otherInterPort,
                                                                 vieConfig); // 要判断返回值
                     } else {
                         ret = self.pInterfaceApi->StartVoeMedia(argc.otherInterIP,
                                                                 argc.otherInterPort);
                     }
                 } else {
                     NSLog(@"转发可用[%s:%d]", argc.otherForwardIP, argc.otherForwardPort);
                     if (isVideo) {
                         ret = self.pInterfaceApi->StartVieMedia(argc.otherForwardIP,
                                                                 argc.otherForwardPort,
                                                                 vieConfig); // 要判断返回值
                     } else {
                         ret = self.pInterfaceApi->StartVoeMedia(argc.otherForwardIP,
                                                                 argc.otherForwardPort);
                     }
                     //                [[NSNotificationCenter defaultCenter]
                     // postNotificationName:CLOSE_REMOTE_VIEW_FOR_RELAY_TRANSPORT
                     // object:nil];
                     //                ret =
                     // self.pInterfaceApi->StartVoeMedia(argc.otherForwardIP,
                     // argc.otherForwardPort);// 要判断返回值
                 }
                 if (!ret) {
                     //                [[IMTipImp defaultTip] errorTip:@"传输通道开启失败"];
                 }
                 
                 if (ret) {
                     //                [[IMTipImp defaultTip]
                     // showTip:@"紧接着p2p,媒体开启成功"];
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:P2PTUNNEL_SUCCESS
                      object:nil
                      userInfo:params];
                 } else {
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:P2PTUNNEL_FAILED
                      object:nil
                      userInfo:params];
                 }
             });
         });

        
     }];
    [self.keepAlive subscribeNext:^(NSArray *pa) {
        NSString *probeServerIP=[pa objectAtIndex:0];
        NSInteger port=[[pa objectAtIndex:1] integerValue];
        u_int8_t tick = 0xFF;
        self.pInterfaceApi->SendUserData(&tick, sizeof(u_int8_t), [probeServerIP UTF8String], port);
    }];
}

- (NSDictionary *)endPointAddressWithProbeServer:(NSString *)probeServerIP
                                            port:(NSInteger)probeServerPort
                                         bakPort:(NSInteger)bakPort {
    //#if DEBUG
    //    [[IMTipImp defaultTip] showTip:@"开始外网地址探测"];
    //#endif
    char self_inter_ip[16];
    uint16_t self_inter_port;
    //获取本机外网ip和端口
    // 1st time
    NSLog(@"use backport:%d for the 1st get", bakPort);
    self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String], bakPort,
                                         self_inter_ip, self_inter_port);
    // 2nd time
    NSLog(@"use probeport:%d for the 2nd get", probeServerPort);
    int ret = self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String],
                                                   probeServerPort, self_inter_ip,
                                                   self_inter_port);
    if (ret != 0) {
        self.currentInterIP = BLANK_STRING;
        //#if DEBUG
        //        [[IMTipImp defaultTip]
        // showTip:@"没有获取到本机的外网地址.很有可能转发哦"];
        //#endif
    } else {
        self.currentInterIP = [NSString stringWithUTF8String:self_inter_ip];
    }
    return @{
             kPeerInterIP : self.currentInterIP,
             kPeerPort : [NSNumber numberWithInt:self_inter_port],
             kPeerLocalIP : [[self class] localAddress],
             kPeerLocalPort : [NSNumber numberWithInt:self.netWorkPort]
             };
}
+ (NSString *)localAddress {
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if (!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if (sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr =
                [NSString stringWithUTF8String:
                 inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)
                           ->sin_addr)]; // pdp_ip0
                
                if ([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else if ([name isEqualToString:@"pdp_ip0"]) {
                    // Interface is the cell connection on the iPhone
                    cellAddress = addr;
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    
    return addr;
}
+(int)getNatType{
    NatTypeImpl nat;
    
    return nat.GetNatType([[[ItelAction action]getHost].stunServer UTF8String]);
}
@end
