//
//  DialViewModel.h
//  DIalViewSence
//
//  Created by nsc on 14-4-24.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "rootViewModel.h"

@class  IMService;
typedef NS_ENUM(NSInteger, ViewType){
    ViewTypeVCalling,
    ViewTypeVAnsering,
    ViewTypeVsession,
    ViewTypeACalling,
    ViewTypeAAnsering,
    ViewTypeAsession,
    ViewTypeDialing
};
@interface DialViewModel : NSObject
@property (nonatomic,weak) IMService *imService;
@property  (nonatomic,weak) RootViewModel  *modelService;
@property  (nonatomic,strong) NSNumber *showingView;   //当前显示窗口 见ViewType
@property  (nonatomic,strong) UIView *peerSessionView;  //对方的影像
@property  (nonatomic,strong) UIView *localSessionView;  //自己的影像
@property  (nonatomic,strong) NSNumber *isPeerLarge;    //bool 那个图像做大窗口
@property  (nonatomic,strong) NSNumber *isMicOn;   //bool 麦克风开关
@property  (nonatomic,strong) NSNumber *isSoundOn; // bool 扬声器开关
@property  (nonatomic,strong) NSNumber *isLocalCameraOn; //bool 本地摄像头开关
@property  (nonatomic,strong) NSNumber *smallSessionView; // bool 隐藏小窗口
@property  (nonatomic,strong) NSNumber *useFrontCamera; //bool 前后摄像头切换
@property  (nonatomic,strong) NSString *systemTime;
@property  (nonatomic,strong) NSString *peerName; //对方名字
@property  (nonatomic,strong) NSString *peerNum;//对方号码
@property  (nonatomic,strong) NSString *connectionState;// 连接状态 如：正在建立连接
@property  (nonatomic,strong) NSNumber *localCanVideo; //本地是否视频接听
@property  (nonatomic,strong) NSString *peerArea;  //对方地址 如 重庆 南岸区
@property  (nonatomic,strong) UIImage  *peerHeader; //对方头像
-(void)changeCamera;   //交换摄像头
-(void)micSetted;      // 设置mic
-(void)soundSetted;     // 设置扬声器
-(void)localCameraOnSetted; // 设置本地摄像头开启
-(void)smallSessionShowSetted; // 隐藏小窗口
-(void)sessionComplete; // 结束通话信号
-(void)answer;           //接听来电
-(void)hideDialingSessionView; //隐藏拨号盘
-(void)dial:(NSString*)itel useVideo:(BOOL)useVideo;

@end
