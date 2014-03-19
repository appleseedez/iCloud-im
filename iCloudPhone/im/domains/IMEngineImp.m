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

UIView*  _pview_local;
@interface IMEngineImp ()
@property(atomic) CAVInterfaceAPI* pInterfaceApi;
@property(nonatomic) InitType m_type;
@property(nonatomic,copy) NSString* currentInterIP;
@property(nonatomic) int cameraIndex;
@property(nonatomic) BOOL isCameraOpened;
@property(nonatomic) int netWorkPort;
@property(nonatomic) dispatch_queue_t q;
@property(nonatomic) dispatch_queue_t m;
@property(atomic) BOOL p2pFinished;
@property(nonatomic) int selfNATType;
@property(nonatomic,copy) NSString* stunServer;
@end
static BOOL firstOpenCam = YES;
@implementation IMEngineImp
- (id)init{
    if (self = [super init]) {
        self.canVideoCalling = YES;
        self.cameraIndex = 1;
        self.isCameraOpened = NO;
        self.netWorkPort = LOCAL_PORT;
        self.pInterfaceApi =new CAVInterfaceAPI();
        self.q = dispatch_queue_create("com.itelland.p2ptunnelprivatequeue", NULL);//dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0); //dispatch_queue_create("com.itelland.p2ptunnelprivatequeue", NULL );//
        self.m =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);//dispatch_queue_create("com.itelland.stopP2Pprivatequeue", NULL );
        _pview_local = [[UIView alloc] initWithFrame:CGRectMake(0, 0,FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
        self.p2pFinished = YES;
    }
    return self;
}

- (BOOL)isP2PFinished{
    return self.p2pFinished;
}

-(dispatch_queue_t)p2pQueue{
    return self.q;
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
        case UIInterfaceOrientationPortrait: degrees = 180; break;
        case UIInterfaceOrientationLandscapeLeft: degrees = 270; break;
        case UIInterfaceOrientationPortraitUpsideDown: degrees = 0; break;
        case UIInterfaceOrientationLandscapeRight: degrees = 90; break;
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
    if (false == self.pInterfaceApi->OpenNetWork(self.netWorkPort)) {

    }else{
    }
}
/**
 *  初始化本机的媒体库。 根据网络状况确定是否支持视频
 */
- (void)initMedia{
    // TODO:在媒体初始化时,获取访问摄像头和麦克的权限. 另外如果没有获取到这些权限应该怎么办?
    self.pInterfaceApi->MediaInit();
    //初始化媒体时获取一次本机的nat
    [self setCurrentNATType:[self natType]];
    //接下来，本地根据网络情况，会重新评估一次是否支持视频
    AFNetworkReachabilityManager* reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //网络发生变化时,再次获取nat
        [self setCurrentNATType:[self natType]];
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
            {
                //是支持视频的
                self.m_type = InitTypeVoeAndVie;
            }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            {
                //由于使用3g网络。不支持视频
                self.m_type = InitTypeVoeAndVie;
//                _pview_local = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0,0)];
            }
            case AFNetworkReachabilityStatusNotReachable:
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NO_CONNECTION_NOTIFICATION object:nil];
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
    
    return nat.GetNatType([self.stunServer UTF8String]);
//    return nat.GetNatType("stun.fwdnet.net:3478");
}

- (NSDictionary*)endPointAddressWithProbeServer:(NSString*) probeServerIP port:(NSInteger) probeServerPort bakPort:(NSInteger) bakPort{
//#if DEBUG
//    [[IMTipImp defaultTip] showTip:@"开始外网地址探测"];
//#endif
    char self_inter_ip[16];
    uint16_t self_inter_port;
    //获取本机外网ip和端口
// 1st time
    NSLog(@"use backport:%d for the 1st get",bakPort);
    self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String], bakPort, self_inter_ip, self_inter_port);
    // 2nd time
    NSLog(@"use probeport:%d for the 2nd get",probeServerPort);
    int ret = self.pInterfaceApi->GetSelfInterAddr([probeServerIP UTF8String], probeServerPort, self_inter_ip, self_inter_port);
    if (ret != 0) {
        self.currentInterIP = BLANK_STRING;
//#if DEBUG
//        [[IMTipImp defaultTip] showTip:@"没有获取到本机的外网地址.很有可能转发哦"];
//#endif
    }else{
        self.currentInterIP =[NSString stringWithUTF8String:self_inter_ip];
    }
    return @{
             kPeerInterIP: self.currentInterIP,
             kPeerPort:[NSNumber numberWithInt:self_inter_port],
             kPeerLocalIP:[[self class] localAddress],
             kPeerLocalPort:[NSNumber numberWithInt:self.netWorkPort]
             };
}
- (int)tunnelWith:(NSDictionary*) params{
    bool __block ret = true;
    TP2PPeerArgc __block argc;
 
    dispatch_async(self.q, ^{
        //
        NSLog(@"开始获取p2p通道,%@", [NSDate date]);
        
        //根据传入的useVideo参数,确定最终穿透以后是走音频还是视频.
        if ([self canVideoCalling]&&[[params valueForKey:kUseVideo] boolValue]) {
            self.m_type = InitTypeVoeAndVie;
        }else{
            self.m_type = InitTypeVoe;
        }
        NSLog(@"穿透时使用的类型:%@",[self mediaTypeString:self.m_type]);
        NSLog(@"穿透时使用的NAT类型:%@",[params valueForKey:kPeerNATType]);
        // 外网地址
        ::strncpy(argc.otherInterIP, [[params valueForKey:kPeerInterIP] UTF8String], sizeof(argc.otherInterIP));
        argc.otherInterPort = [[params valueForKey:kPeerPort] intValue];
        // 内网地址
        ::strncpy(argc.otherLocalIP, [[params valueForKey:kPeerLocalIP] UTF8String], sizeof(argc.otherLocalIP));
        argc.otherLocalPort =  [[params valueForKey:kPeerLocalPort] intValue];
        // 转发地址
        ::strncpy(argc.otherForwardIP,[[params valueForKey:kRelayIP] UTF8String], sizeof(argc.otherForwardIP));
        argc.otherForwardPort = [[params valueForKey:kRelayPort] intValue];
        
        // 对方的ssid
        argc.otherSsid = [[params valueForKey:kDestSSID] intValue];
        // 自己的ssid
        argc.selfSsid = [[params valueForKey:kSrcSSID] intValue];
        
        argc.otherNATType =[[params valueForKey:kPeerNATType] intValue];
        argc.selfNATType = self.currentNATType;
        //如果内网的ip相同.设置argc.localable = true;
        
        if ([self.currentInterIP isEqualToString:[NSString stringWithUTF8String:argc.otherInterIP]]
            || [self.currentInterIP isEqualToString:BLANK_STRING ]|| [[NSString stringWithUTF8String:argc.otherInterIP] isEqualToString:BLANK_STRING ]) {
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
            NSLog(@"媒体类型:%d",self.m_type);
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
            long long  dTime =endTime - startTime;
            NSLog(@"调用时间间隔：%@",[NSString stringWithFormat:@"%llu",dTime]);
            //如果p2p失败, 立即通知
            if (ret == false) {
                NSLog(@"execute here5");
                [[NSNotificationCenter defaultCenter] postNotificationName:P2PTUNNEL_FAILED object:nil userInfo:params];
                return;
            }
            NSLog(@"isLocal的状态：%d",argc.islocal);
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
            if (argc.islocal)
            {
                NSLog(@"内网可用[%s:%d]", argc.otherLocalIP, argc.otherLocalPort);
                if (self.canVideoCalling ) {
                    ret = self.pInterfaceApi->StartVieMedia(argc.otherLocalIP, argc.otherLocalPort,vieConfig);// 要判断返回值
                }else{
                    ret = self.pInterfaceApi->StartVoeMedia(argc.otherLocalIP, argc.otherLocalPort);
                }
            }
            else if (argc.isInter)
            {
                NSLog(@"外网可用[%s:%d]", argc.otherInterIP, argc.otherInterPort);
                if (self.canVideoCalling) {
                    ret = self.pInterfaceApi->StartVieMedia(argc.otherInterIP, argc.otherInterPort,vieConfig);// 要判断返回值
                }else{
                    ret = self.pInterfaceApi->StartVoeMedia(argc.otherInterIP, argc.otherInterPort);
                }
            }
            else
            {
                NSLog(@"转发可用[%s:%d]", argc.otherForwardIP, argc.otherForwardPort);
                [[NSNotificationCenter defaultCenter] postNotificationName:CLOSE_REMOTE_VIEW_FOR_RELAY_TRANSPORT object:nil];
                ret = self.pInterfaceApi->StartVoeMedia(argc.otherForwardIP, argc.otherForwardPort);// 要判断返回值
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
    bool retCloseMedia = true;
    bool retCloseNet = NO;
    if (self.canVideoCalling) {
        self.pInterfaceApi->SwitchCamera(10);
        retCloseMedia    = self.pInterfaceApi->StopVieMedia();
    }else{
        retCloseMedia = self.pInterfaceApi->StopVoeMedia();
    }
    if (self.p2pFinished) {
       retCloseNet =  self.pInterfaceApi->CloseNetWork();
    }
    if (retCloseMedia &&retCloseNet) {
        self.isCameraOpened = NO;
    }
    //在结束通话时,将音频session终止
//    NSError* error= Nil;
//    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    NSLog(@"<<<<<<<<<<<<<<<<<<<<closeMedia:%d,closeNet:%d >>>>>>>>>>>>>>>>>>>>>>>>>>>>",retCloseMedia,retCloseNet);
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
}
- (void)hideCam{
#if ENGINE_MSG
    NSLog(@"隐藏摄像头");
#endif
    self.pInterfaceApi->StopCamera();
}

@synthesize canVideoCalling = _canVideoCalling;
- (void)setCanVideoCalling:(BOOL)canVideoCalling{
    _canVideoCalling = canVideoCalling;
}
- (BOOL)canVideoCalling{
    return _canVideoCalling;
}
- (int)openScreen:(VideoRenderIosView*) remoteRenderView{
    if (!remoteRenderView) {
        return 0;
    }
    int ret = 0;
    if (self.isCameraOpened )
    {
//        [[IMTipImp defaultTip] showTip:@"设置小窗口"];
        // 摆正摄像头位置
        self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(self.cameraIndex)]);
        // 开启摄像头
        ret = self.pInterfaceApi->VieAddRemoteRenderer((__bridge void*)remoteRenderView);
    }
    return ret;
    
}

- (BOOL) openCamera{
    dispatch_sync(self.q, ^{
        int r = 0;
        //先把摄像头关了
        if ((r = self.pInterfaceApi->StartCamera(self.cameraIndex)) >= 0) {
            if (firstOpenCam) {
                firstOpenCam = NO;
            }else{
                self.pInterfaceApi->ConnectCaptureDevice();
            }
            
            self.isCameraOpened = YES;
            // 摆正摄像头位置
            self.pInterfaceApi->VieSetRotation([self getCameraOrientation:self.pInterfaceApi->VieGetCameraOrientation(self.cameraIndex)]);
            NSLog(@"本地摄像头开启成功");
            //当摄像头开启成功, 把_pview_local作为通知内容发出去
            dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_CAMERA_SUCCESS_NOTIFICATION object:Nil userInfo:@{
                                                                                                @"preview":_pview_local
                                                                                                }];
            });
        }else{
            NSLog(@"摄像头开启失败:%d",r);
            [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_CAMERA_FAILED_NOTIFICATION object:nil userInfo:nil];
            self.isCameraOpened = NO;
        }
    });
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
        //当摄像头开启成功, 把_pview_local作为通知内容发出去
         [[NSNotificationCenter defaultCenter] postNotificationName:OPEN_CAMERA_SUCCESS_NOTIFICATION object:Nil userInfo:@{
                                                                                                                           @"preview":_pview_local
                                                                                                                           }];
    }
    
}
- (void)tearDown{
    bool ret  = self.pInterfaceApi->Terminate(); NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<关闭引擎>>>>>>>>>>>>>>:%d",ret);
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
    int __block ret = -1;
    if (_pInterfaceApi == nil) {
        return ret;
    }
    dispatch_async(self.m, ^{
        NSLog(@"stopp2p start");
        ret  = _pInterfaceApi -> StopDetect();
        NSLog(@"<<<<<<<<<<<<<<<终止P2P>>>>>>>>>> :%d",ret);
        NSLog(@"stopp2p end");
    });



    return 0;
}

- (int)currentNATType{
    return self.selfNATType;
}
- (void) setCurrentNATType:(int)nat{
    self.selfNATType = nat;
}

- (void)setSTUNSrv:(NSString *)stunServer{
    self.stunServer = stunServer;
}
@end
