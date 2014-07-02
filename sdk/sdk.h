//
//  sdk.h
//  sdk
//
//  Created by nsc on 14-5-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIView;
@interface sdk : NSObject
@property(nonatomic) BOOL canVideoCalling;
@property(nonatomic) BOOL isCameraOpened;
-(UIView*)pViewLocal;
//初始化网络
- (void) initNetwork;
//初始化媒体库
- (void) initMedia;
//获取natType
//- (NatType) natType;
//获取本机端点地址
- (NSDictionary*)endPointAddressWithProbeServer:(NSString*) probeServerIP port:(NSInteger) probeServerPort bakPort:(NSInteger) bakPort;
//获取p2p通道
- (int) tunnelWith:(NSDictionary*) params;
//开始传输
- (BOOL) startTransport;
//终止传输
- (void) stopTransport;
//静音
- (void) mute;
- (void) unmute;
- (void) enableSpeaker;
- (void) disableSpeaker;
- (void) showCam;
- (void) hideCam;
- (void)setCanVideoCalling:(BOOL)canVideoCalling;
- (BOOL)canVideoCalling;
//开启远端视频输入窗口
- (int) openScreen:(UIView*) remoteRenderView;
//关闭远端视频输入窗口
- (void) closeScreen;
- (void) switchCamera;
- (void) tearDown;
- (void) keepSessionAlive:(NSString*) probeServerIP port:(NSInteger) port;
- (int) countTopSize; //统计每秒的数据传输量
- (int) stopDetectP2P;
- (BOOL) openCamera;
- (dispatch_queue_t) p2pQueue;
- (BOOL) isP2PFinished;

- (int) currentNATType;
- (void) setCurrentNATType:(int) nat;
- (void) setSTUNSrv:(NSString*) stunServer;

@end