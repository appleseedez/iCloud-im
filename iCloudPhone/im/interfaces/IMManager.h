//
//  IMManager.h
//  im
//
//  Created by Pharaoh on 13-11-20.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConstantHeader.h"
#import "video_render_ios_view.h"
@protocol IMManager <NSObject>
- (NSString*) myAccount;
- (NSDictionary*) myState;
//由外部设置
- (void) setMyAccount:(NSString*) account; //登陆后的本机账号
- (void) setRouteSeverIP:(NSString*) ip;//登陆后的路由服务器地址
- (void) setRouteServerPort:(u_int16_t) port;//登陆后的路由服务器端口
//拨号
- (void) dial:(NSString*) account;
// 开始通话过程. 返回YES表示开启通话过程成功.可以继续.否则后续流程终止
- (BOOL) sessionStartedWithAccount:(NSString*) destAccount;
// 结束通话过程
- (void) endSession;
// 初始化&启动
- (void) setup;
// 连接服务器
- (void) connectToSignalServer;
// 断开连接
-(void) disconnectToSignalServer;
// 在app从后台回到前台时,检查心跳是否还在.
- (void) checkTCPAlive;
-(void) sendCallingData;
-(void) clearTable;
//从信令业务服务器注销
- (void) logoutFromSignalServer;
//销毁
- (void) tearDown;
//接受通话请求
- (void) acceptSession:(NSNotification*) notify;
// 终止通话请求
- (void)haltSession:(NSDictionary*) data;
- (void) lockScreenForSession;
- (void) unlockScreenForSession;
//设置视频输出窗口
- (int) openScreen:(VideoRenderIosView*) remoteRenderView;
//关闭视频窗口
- (void) closeScreen;
//静音
- (void) mute;
//取消静音
- (void) unmute;
- (void) enableSpeaker;
- (void) disableSpeaker;
- (void) showCam;
- (void) hideCam;
- (void) showSelfCam;
- (void) hideSelfCam;
- (void) switchCamera;
//告诉manager 是视频通话。 这个只是参考值， 最终是否是视频还要双方协商确定
- (void) setIsVideoCall:(BOOL)isVideoCall;
- (BOOL) isVideoCall;
- (void) setCanVideo:(BOOL)canVideo;
- (BOOL) canVideo;
- (double) checkDuration;
- (void) presentDialRelatedPanel:(UIViewController*) rootViewController;
- (void) dismissDialRelatedPanel;
- (void) sendHeartbeat;
@end
