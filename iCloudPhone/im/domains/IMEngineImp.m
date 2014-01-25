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

#import "IMTipImp.h"
UIImageView* _pview_local;
@interface IMEngineImp ()
@property(nonatomic) CAVInterfaceAPI* pInterfaceApi;
@property(nonatomic) InitType m_type;
@property(nonatomic,copy) NSString* currentInterIP;
@property(nonatomic) int cameraIndex;
@property(nonatomic) BOOL isCameraOpened;
@property(nonatomic) int netWorkPort;
@end

@implementation IMEngineImp
- (id)init{
    if (self = [super init]) {
            self.canVideoCalling = YES;
            self.cameraIndex = 1;
            self.isCameraOpened = NO;
            self.netWorkPort = LOCAL_PORT;
            _pview_local = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
    }
    return self;
}
- (CAVInterfaceAPI *)pInterfaceApi{
    if (_pInterfaceApi == nil) {
        _pInterfaceApi = new CAVInterfaceAPI();
    }
    return _pInterfaceApi;
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
static int localNetPortSuffix = 0;
// IMEngine接口 见接口定义
- (void)initNetwork{
    self.netWorkPort = LOCAL_PORT + (++localNetPortSuffix)%9;
    if (false == self.pInterfaceApi->NetWorkInit(self.netWorkPort)) {
//        [NSException exceptionWithName:@"400: init network failed" reason:@"引擎初始化网络失败" userInfo:nil];
        [[IMTipImp defaultTip] errorTip:@"引擎初始化网络失败"];
    }else{
        [self initMedia];
    }
}
/**
 *  初始化本机的媒体库。 根据网络状况确定是否支持视频
 */
- (void)initMedia{
    // 首先，初始化媒体。此时返回的m_type可以表明本机是否有能力进行视频。
    self.m_type = self.pInterfaceApi->MediaInit(SCREEN_WIDTH,SCREEN_HEIGHT,InitTypeVoeAndVie);
   // TODO:在媒体初始化时,获取访问摄像头和麦克的权限. 另外如果没有获取到这些权限应该怎么办?


    
    
   //接下来，本地根据网络情况，会重新评估一次是否支持视频
    AFNetworkReachabilityManager* reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[IMTipImp defaultTip] showTip:[NSString stringWithFormat:@"当前网络:%@",AFStringFromNetworkReachabilityStatus(status)]];
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //是支持视频的
                self.m_type = InitTypeVoeAndVie;
//                _pview_local = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
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
        switch (self.m_type) {
            case InitTypeVoe:
                [self setCanVideoCalling:NO];
                break;
            case InitTypeVoeAndVie:
                [self setCanVideoCalling:YES];
                break;
            default:
                break;
        }
    }];
    [[IMTipImp defaultTip] showTip:[self mediaTypeString:self.m_type]];
    [reachabilityManager startMonitoring];

}

- (NSString*) mediaTypeString:(InitType)mediaType{
    NSString* typeString = BLANK_STRING;
    switch (mediaType) {
        case InitTypeNone:
            typeString = @"未知类型";
            break;
        case InitTypeVoe:
            typeString = @"音频类型";
            break;
        case InitTypeVoeAndVie:
            typeString = @"视频类型";
            break;
            
        default:
            break;
    }
    return typeString;
}

- (NatType)natType{
    NatTypeImpl nat;
    return nat.GetNatType("stun.fwdnet.net:3478");
}

- (NSDictionary*)endPointAddressWithProbeServer:(NSString*) probeServerIP port:(NSInteger) probeServerPort{
//    [[IMTipImp defaultTip] showTip:@"开始外网地址探测"];
    char self_inter_ip[16];
    uint16_t self_inter_port;
    //获取本机外网ip和端口
    int ret = self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String], probeServerPort, self_inter_ip, self_inter_port);
    if (ret != 0) {
        self.currentInterIP = BLANK_STRING;
        [[IMTipImp defaultTip] showTip:@"没有获取到本机的外网地址.很有可能转发哦"];
    }else{
        self.currentInterIP =[NSString stringWithUTF8String:self_inter_ip];
    }
    return @{
            SESSION_PERIOD_FIELD_PEER_INTER_IP_KEY: self.currentInterIP,
             SESSION_PERIOD_FIELD_PEER_INTER_PORT_KEY:[NSNumber numberWithInt:self_inter_port],
             SESSION_PERIOD_FIELD_PEER_LOCAL_IP_KEY:[[self class] localAddress],
             SESSION_PERIOD_FIELD_PEER_LOCAL_PORT_KEY:[NSNumber numberWithInt:self.netWorkPort]
             };
}

- (int)tunnelWith:(NSDictionary*) params{
    bool __block ret = true;
    TP2PPeerArgc __block argc;
    dispatch_queue_t q =// dispatch_get_main_queue();// dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_queue_create("com.itelland.p2ptunnelprivatequeue", NULL );
    dispatch_async(q, ^{
        //
        NSLog(@"开始获取p2p通道,%@", [NSDate date]);

        //根据传入的useVideo参数,确定最终穿透以后是走音频还是视频.
        if ([self canVideoCalling]&&[[params valueForKey:SESSION_PERIOD_FIELD_PEER_USE_VIDEO] boolValue]) {
            self.m_type = InitTypeVoeAndVie;
        }else{
            self.m_type = InitTypeVoe;
        }
        NSLog(@"穿透时使用的类型:%@",[self mediaTypeString:self.m_type]);
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

        NSLog(@"本机的外网ip：%@",self.currentInterIP);
        NSLog(@"对方的外网ip：%@",[NSString stringWithUTF8String:argc.otherInterIP]);
        NSLog(@"设置localable为：%d",argc.localEnble);
        NSLog(@"通话参数：对方外网ip：%s",argc.otherInterIP);
        NSLog(@"通话参数：对方外网port：%i",argc.otherInterPort);
        NSLog(@"通话参数：对方内网ip：%s",argc.otherLocalIP);
        NSLog(@"通话参数：对方内网port:%i",argc.otherLocalPort);
        NSLog(@"通话参数：对方ssid：%i",argc.otherSsid);
        NSLog(@"通话参数：自己ssid：%i",argc.selfSsid);
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        
        if (self.pInterfaceApi->GetP2PPeer(argc) != 0) {
//            return -1;
            ret = false;
        }
        //如果已经完成p2p穿透,就终止
//        self.pInterfaceApi->StopDetect();
        dispatch_async(dispatch_get_main_queue(), ^{
//              [[IMTipImp defaultTip] showTip:@"<<<<<<p2p成功>>>>>>>"];
            NSLog(@"媒体类型:%d",self.m_type);
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
            long long  dTime =endTime - startTime;
            NSLog(@"调用时间间隔：%@",[NSString stringWithFormat:@"%llu",dTime]);
            //如果p2p失败, 立即通知
            if (ret == false) {
                [[NSNotificationCenter defaultCenter] postNotificationName:P2PTUNNEL_FAILED object:nil userInfo:params];
                return;
            }
            NSLog(@"isLocal的状态：%d",argc.islocal);
//            [[IMTipImp defaultTip] showTip:@"准备startmedia"];
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
//                [[IMTipImp defaultTip] errorTip:@"传输通道开启失败"];
            }

            if (ret) {
//                [[IMTipImp defaultTip] showTip:@"紧接着p2p,媒体开启成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:P2PTUNNEL_SUCCESS object:nil userInfo:params];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:P2PTUNNEL_FAILED object:nil userInfo:params];
            }
        });
    });

    return  ret;
}
- (BOOL)startTransport{
    
    
    return YES;
}

- (void)stopTransport{
    bool ret = self.pInterfaceApi->StopMedia(self.m_type);
    if (ret) {
        self.isCameraOpened = NO;
        NSLog(@"<<<<<<<<<<<<<<<<<<<<关闭传输通道成功：>>>>>>>>>>>>>>>>>>>>>>%d",ret);
    }
}

- (void)mute{
#if ENGINE_MSG
    NSLog(@"静音");
#endif
    self.pInterfaceApi->SetMuteEnble(MTVoe, false);
}
- (void) unmute{
#if ENGINE_MSG
    NSLog(@"取消静音");
#endif
    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}
- (void)enableSpeaker{
#if ENGINE_MSG
    NSLog(@"TODO:开扬声器");
#endif
    NSError* error = nil;
    [[AVAudioSession sharedInstance]setActive:YES error:&error];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    if (error) {
#if ENGINE_MSG
        [NSException exceptionWithName:@"audioSession error" reason:@"audioSession error" userInfo:nil];
#endif
    }
}

- (void)disableSpeaker{
#if ENGINE_MSG
    NSLog(@"TODO:关扬声器");
#endif
    NSError* error = nil;
    [[AVAudioSession sharedInstance]setActive:YES error:&error];
    [[AVAudioSession sharedInstance]setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
    if (error) {
#if ENGINE_MSG
        [NSException exceptionWithName:@"audioSession error" reason:@"audioSession error" userInfo:nil];
#endif
    }
}
- (void)showCam{
#if ENGINE_MSG
    NSLog(@"显示摄像头");
#endif
    [self openCamera];
//    self.pInterfaceApi->SetMuteEnble(MTVie, true);
//    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}
- (void)hideCam{
#if ENGINE_MSG
    NSLog(@"隐藏摄像头");
#endif
    self.pInterfaceApi->SwitchCamera(10);
//    self.pInterfaceApi->SetMuteEnble(MTVie, false);
//    self.pInterfaceApi->SetMuteEnble(MTVoe, true);
}

@synthesize canVideoCalling = _canVideoCalling;
- (void)setCanVideoCalling:(BOOL)canVideoCalling{
    _canVideoCalling = canVideoCalling;
}
- (BOOL)canVideoCalling{
    return _canVideoCalling;
}
- (void)openScreen:(VideoRenderIosView*) remoteRenderView localView:(UIView *)localView{
    if (!remoteRenderView) {
        return;
    }
        if (self.isCameraOpened )
        {
//            [[IMTipImp defaultTip] showTip:@"设置小窗口"];
            // 摆正摄像头位置
            self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(self.cameraIndex)]);
            // 开启摄像头
            [_pview_local setFrame:CGRectMake(0, 0, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
            [localView addSubview:_pview_local];
            [localView setFrame:CGRectMake(FULL_SCREEN.size.width*.7, FULL_SCREEN.size.height*.7, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
            self.pInterfaceApi->VieAddRemoteRenderer((__bridge void*)remoteRenderView);


        }
  

}

- (BOOL) openCamera{
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int r = 0;
        //先把摄像头关了
        self.pInterfaceApi->SwitchCamera(10);
        if ((r = self.pInterfaceApi->StartCamera(self.cameraIndex)) >= 0) {
            self.isCameraOpened = YES;
            // 摆正摄像头位置
            self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(self.cameraIndex)]);
        }else{
            NSLog(@"摄像头关闭失败:%d",r);
            self.isCameraOpened = NO;
        }
    });
NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    long long duration =endTime-startTime;
//    [[IMTipImp defaultTip] showTip:[NSString stringWithFormat:@"开启摄像头耗时:%llu",duration]];
    return self.isCameraOpened;
}
- (void)closeScreen{
}
- (void) switchCamera{
    
    switch (self.cameraIndex) {
        case 0:
            self.cameraIndex = 1;
            break;
        case 1:
            self.cameraIndex = 0;
            break;
        default:
            self.cameraIndex = 1;
            break;
    }
    if (self.isCameraOpened) {
            self.pInterfaceApi->SwitchCamera(self.cameraIndex);
            // 摆正摄像头位置
            self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(self.cameraIndex)]);

    }

}
- (void)tearDown{
    [self stopTransport];
    bool ret  = self.pInterfaceApi->Terminate();
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<关闭引擎>>>>>>>>>>>>>>:%d",ret);
    delete _pInterfaceApi;
    _pInterfaceApi = nil;
    

}

- (void)keepSessionAlive:(NSString*) probeServerIP port:(NSInteger)port{
    u_int8_t tick = 0xFF;
    self.pInterfaceApi->SendUserData(&tick, sizeof(u_int8_t), [probeServerIP UTF8String], port);
}
- (int)countTopSize{
    return self.pInterfaceApi->GetTopMediaDataSize();
}


- (int) stopDetectP2P{
    if (_pInterfaceApi == nil) {
        return -1;
    }
    int ret  = self.pInterfaceApi -> StopDetect();
    NSLog(@"<<<<<<<<<<<<<<<终止P2P>>>>>>>>>> :%d",ret);
    return ret;
}
@end
