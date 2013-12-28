//
//  IMEngineImp.m
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMEngineImp.h"
#import "AVInterface.h"
#import "NatTypeImpl.h"
#import "ConstantHeader.h"
#import "video_render_ios_view.h"
UIImageView* _pview_local;
@interface IMEngineImp ()
@property(nonatomic) CAVInterfaceAPI* pInterfaceApi;
@property(nonatomic) InitType m_type;
@property(nonatomic,copy) NSString* currentInterIP;
@property(nonatomic) BOOL isVideoCalling;
@end

@implementation IMEngineImp
- (id)init{
    if (self = [super init]) {
        if (_pInterfaceApi == nil) {
            _pInterfaceApi = new CAVInterfaceAPI();
        }
    }
    return self;
}

+ (NSString*) localAddress{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                //NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself
                
                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;
                } else
                    if([name isEqualToString:@"pdp_ip0"]) {
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
    
#if ENGINE_MESSAGE
    NSLog(@">>>>>>>>>本机ip地址: %@",addr);
#endif
    return addr;
}

-(NSInteger) getCameraOrientation:(NSInteger) cameraOrientation
{
    UIInterfaceOrientation displatyRotation = [[UIApplication sharedApplication] statusBarOrientation];
    NSInteger degrees = 0;
    switch (displatyRotation) {
        case UIInterfaceOrientationPortrait: degrees = 0; break;
        case UIInterfaceOrientationLandscapeLeft: degrees = 90; break;
        case UIInterfaceOrientationPortraitUpsideDown: degrees = 180; break;
        case UIInterfaceOrientationLandscapeRight: degrees = 270; break;
    }
    
    NSInteger result = 0;
    if (cameraOrientation > 180) {
        result = (cameraOrientation + degrees) % 360;
    } else {
        result = (cameraOrientation - degrees + 360) % 360;
    }
    
    return result;
}


#pragma mark - INTERFACE

// IMEngine接口 见接口定义
- (void)initNetwork{
    if (false == self.pInterfaceApi->NetWorkInit(LOCAL_PORT)) {
        [NSException exceptionWithName:@"400: init network failed" reason:@"引擎初始化网络失败" userInfo:nil];
    }
}
/**
 *  初始化本机的媒体库。 根据网络状况确定是否支持视频
 */
- (void)initMedia{
    // 首先，初始化媒体。此时返回的m_type可以表明本机是否有能力进行视频。
    self.m_type = self.pInterfaceApi->MediaInit(SCREEN_WIDTH,SCREEN_HEIGHT,InitTypeNone);
   //接下来，本地根据网络情况，会重新评估一次是否支持视频
    AFNetworkReachabilityManager* reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //
        NSLog(@"检查当前的链接状态:%@",AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //是支持视频的
                self.m_type = InitTypeVoeAndVie;
                _pview_local = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                //由于使用3g网络。不支持视频
                self.m_type = InitTypeVoe;
                _pview_local = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
            }
                break;
            default:
                break;
        }
    }];
    NSLog(@"媒体类型：%d",self.m_type);
    [reachabilityManager startMonitoring];

}

- (NatType)natType{
    NatTypeImpl nat;
    return nat.GetNatType("stun.fwdnet.net:3478");
}

- (NSDictionary*)endPointAddressWithProbeServer:(NSString*) probeServerIP port:(NSInteger) probeServerPort{
    NSLog(@"外网地址探测服务器地址：%@",probeServerIP);
    char self_inter_ip[16];
    uint16_t self_inter_port;
    //获取本机外网ip和端口
    int ret = self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String], probeServerPort, self_inter_ip, self_inter_port);
    if (ret != 0) {
        self.currentInterIP = BLANK_STRING;
    }else{
        self.currentInterIP =[NSString stringWithUTF8String:self_inter_ip];
    }
    return @{
            SESSION_PERIOD_FIELD_PEER_INTER_IP_KEY: self.currentInterIP,
             SESSION_PERIOD_FIELD_PEER_INTER_PORT_KEY:[NSNumber numberWithInt:self_inter_port],
             SESSION_PERIOD_FIELD_PEER_LOCAL_IP_KEY:[[self class] localAddress],
             SESSION_PERIOD_FIELD_PEER_LOCAL_PORT_KEY:[NSNumber numberWithInt:LOCAL_PORT]
             };
}

- (int)tunnelWith:(NSDictionary*) params{
    bool __block ret = true;
    dispatch_queue_t q = dispatch_get_main_queue();// dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);// dispatch_queue_create("com.itelland.p2ptunnelprivatequeue", DISPATCH_QUEUE_CONCURRENT );
    dispatch_async(q, ^{
        //
        NSLog(@"开始获取p2p通道,%@", [NSDate date]);
        TP2PPeerArgc argc;

        
        // 外网地址
        ::strncpy(argc.otherInterIP, [[params valueForKey:SESSION_PERIOD_FIELD_PEER_INTER_IP_KEY] UTF8String], sizeof(argc.otherInterIP));
        argc.otherInterPort = [[params valueForKey:SESSION_PERIOD_FIELD_PEER_INTER_PORT_KEY] intValue];
        // 内网地址
        ::strncpy(argc.otherLocalIP, [[params valueForKey:SESSION_PERIOD_FIELD_PEER_LOCAL_IP_KEY] UTF8String], sizeof(argc.otherLocalIP));
        argc.otherLocalPort =  [[params valueForKey:SESSION_PERIOD_FIELD_PEER_LOCAL_PORT_KEY] intValue];
        // 转发地址
        ::strncpy(argc.otherForwardIP,[[params valueForKey:SESSION_INIT_RES_FIELD_FORWARD_IP_KEY] UTF8String], sizeof(argc.otherForwardIP));
        argc.otherForwardPort = [[params valueForKey:SESSION_INIT_RES_FIELD_FORWARD_PORT_KEY] intValue];

        // 对方的ssid
        argc.otherSsid = [[params valueForKey:SESSION_DEST_SSID_KEY] intValue];
        // 自己的ssid
        argc.selfSsid = [[params valueForKey:SESSION_SRC_SSID_KEY] intValue];

        //如果内网的ip相同.设置argc.localable = true;
        
        if ([self.currentInterIP isEqualToString:[NSString stringWithUTF8String:argc.otherInterIP]]) {
            argc.localEnble = true;
        }else{
            argc.localEnble = false;
        }
#if ENGINE_MSG
        NSLog(@"本机的外网ip：%@",self.currentInterIP);
        NSLog(@"对方的外网ip：%@",[NSString stringWithUTF8String:argc.otherInterIP]);
        NSLog(@"设置localable为：%d",argc.localEnble);
        NSLog(@"通话参数：对方外网ip：%s",argc.otherInterIP);
        NSLog(@"通话参数：对方外网port：%i",argc.otherInterPort);
        NSLog(@"通话参数：对方内网ip：%s",argc.otherLocalIP);
        NSLog(@"通话参数：对方内网port:%i",argc.otherLocalPort);
        NSLog(@"通话参数：对方ssid：%i",argc.otherSsid);
        NSLog(@"通话参数：自己ssid：%i",argc.selfSsid);
#endif
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        if (self.pInterfaceApi->GetP2PPeer(argc) != 0) {
//            return -1;
            ret = false;
        }
        NSLog(@"媒体类型:%d",self.m_type);
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        long long  dTime =endTime - startTime;
        NSLog(@"调用时间间隔：%@",[NSString stringWithFormat:@"%llu",dTime]);
        
        NSLog(@"isLocal的状态：%d",argc.islocal);
        if (argc.islocal)
        {
            NSLog(@"内网可用[%s:%d]", argc.otherLocalIP, argc.otherLocalPort);
            ret = self.pInterfaceApi->StartMedia(self.m_type, argc.otherLocalIP, argc.otherLocalPort);// 要判断返回值
        }
        else if (argc.isInter)
        {
            NSLog(@"外网可用[%s:%d]", argc.otherInterIP, argc.otherInterPort);
            ret = self.pInterfaceApi->StartMedia(self.m_type, argc.otherInterIP, argc.otherInterPort);// 要判断返回值
        }
        else
        {
            NSLog(@"转发可用[%s:%d]", argc.otherForwardIP, argc.otherForwardPort);
            ret = self.pInterfaceApi->StartMedia(InitTypeVoe, argc.otherForwardIP, argc.otherForwardPort);// 要判断返回值
        }
        if (!ret)
        {
            NSLog(@"传输初期化失败");
        }
        // 如果穿透操作成功。则发送通知
        
        
        NSLog(@"到底你执行了多少次");
        if (ret) {
            [[NSNotificationCenter defaultCenter] postNotificationName:P2PTUNNEL_SUCCESS object:nil userInfo:params];
        }else{
            [NSException exceptionWithName:@"p2p穿透失败" reason:@"p2p穿透失败" userInfo:nil];
        }

    });

    return  ret;
}
- (BOOL)startTransport{
    
    
    return NO;
}

- (void)stopTransport{
    bool ret = self.pInterfaceApi->StopMedia(self.m_type);
    NSLog(@"关闭传输通道成功：%d",ret);
    //通知界面
//    [[NSNotificationCenter defaultCenter] postNotificationName:END_SESSION_NOTIFICATION object:nil userInfo:nil];
}

- (void)mute{
    NSLog(@"静音");
    self.pInterfaceApi->SetMuteEnble(MTVoe, false);
}
- (void) unmute{
    NSLog(@"取消静音");
    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}
- (void)enableSpeaker{
    NSLog(@"TODO:开扬声器");
}

- (void)disableSpeaker{
    NSLog(@"TODO:关扬声器");
}
- (void)showCam{
    NSLog(@"显示摄像头");
    self.pInterfaceApi->SetMuteEnble(MTVie, true);
    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}
- (void)hideCam{
    NSLog(@"隐藏摄像头");
    self.pInterfaceApi->SetMuteEnble(MTVie, false);
    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}

@synthesize isVideoCalling = _isVideoCalling;
- (void)setIsVideoCalling:(BOOL)isVideoCalling{
    _isVideoCalling = isVideoCalling;
}
- (BOOL)isVideoCalling{
    return _isVideoCalling;
}
- (void)openScreen:(VideoRenderIosView*) remoteRenderView localView:(UIView *)localView{
    // 开启摄像头
    if (self.pInterfaceApi->StartCamera(1) >= 0)
    {
        // 摆正摄像头位置
        self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(0)]);
    }
    [_pview_local setFrame:CGRectMake(0, 0, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
    [localView addSubview:_pview_local];
    [localView setFrame:CGRectMake(FULL_SCREEN.size.width*.7, FULL_SCREEN.size.height*.7, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
    self.pInterfaceApi->VieAddRemoteRenderer((__bridge void*)remoteRenderView);
}
- (void)closeScreen{
}

- (void)tearDown{
    self.pInterfaceApi->Terminate();
}

- (void)keepSessionAlive:(NSString*) probeServerIP port:(NSInteger)port{
    u_int8_t tick = 0xFF;
    self.pInterfaceApi->SendUserData(&tick, sizeof(u_int8_t), [probeServerIP UTF8String], port);
}
@end
