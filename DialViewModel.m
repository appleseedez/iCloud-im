//
//  DialViewModel.m
//  DIalViewSence
//
//  Created by nsc on 14-4-24.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialViewModel.h"
#import "IMService.h"
#import "ItelUser+CRUD.h"
#import "video_render_ios_view.h"
@implementation DialViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imService=[IMService defaultService];
        
       [[RACObserve(self, imService.sessionType) map:^id(NSNumber *value) {
           if ([value integerValue]!=IMsessionTypeEdle) {
               self.modelService.showSessinView=@(YES);
           }
           
           if ([value integerValue]==IMsessionTypeCalling) {
               if ([self.imService.useVideo boolValue]) {
                   self.showingView=@(ViewTypeVCalling);
               }else{
                   self.showingView=@(ViewTypeACalling);
               }
           }else if ([value integerValue]==IMsessionTypeInSession){
               if ([self.imService.useVideo boolValue]) {
                   [self openScreen  ];
                   self.showingView=@(ViewTypeVsession);
                   
               }else{
                   self.showingView=@(ViewTypeAsession);
               }
               
           }else if ([value integerValue]==IMsessionTypeAnsering){
               if ([self.imService.useVideo boolValue]) {
                   self.showingView=@(ViewTypeVAnsering);
               }else{
                   self.showingView=@(ViewTypeAAnsering);
               }
           }
           
            return value;
        }]subscribeNext:^(id x) {}];
        
       
        [[RACObserve(self, imService.sessionState) map:^id(id value) {
            self.connectionState=value;
            return value;
        }]subscribeNext:^(id x) {}];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionCome:) name:@"sessionCome" object:nil];
    }
    return self;
}
-(void)sessionCome:(NSNotification*)notification{
    NSString *type=[notification.userInfo objectForKey:@"type"];
    if ([type isEqualToString:@"call"]) {
        BOOL useVideo=[[notification.userInfo objectForKey:@"useVideo"]boolValue];
        NSString *itel=[notification.userInfo objectForKey:@"itel"];
        [self dial:itel useVideo:useVideo];
    }
   
//    NSDictionary *userInfo=@{@"type":@"call",@"useVideo":@(1),@"itel":};
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionCome" object:nil userInfo:userInfo];

}
-(void)changeCamera{
    BOOL useFrontCamera=[self.useFrontCamera boolValue];
    NSString *state;
    if (useFrontCamera) {
        state=@"前置摄像头";
    }else{
        state=@"后置摄像头";
    }
    self.useFrontCamera=@(!useFrontCamera);
    NSLog(@"本地使用%@",state);
}

-(void)micSetted{
    BOOL isMicOn=[self.isMicOn boolValue];
    NSString *state;
    if (isMicOn) {
        state=@"开启";
    }else{
        state=@"关闭";
    }
    self.isMicOn=@(!isMicOn);
    NSLog(@"本地麦克风%@",state);
}
-(void)soundSetted{
    BOOL isSoundOn=[self.isSoundOn boolValue];
    NSString *state;
    if (isSoundOn) {
        state=@"开启";
    }else{
        state=@"关闭";
    }
    self.isSoundOn=@(!isSoundOn);
    NSLog(@"本地扬声器%@",state);
}
//本地摄像头
-(void)localCameraOnSetted{
    BOOL cameraOn=[self.isLocalCameraOn boolValue];
    NSString *state;
    if (cameraOn) {
         state=@"开启";
    }else{
        state=@"关闭";
    }
    self.isLocalCameraOn=@(!cameraOn);
    NSLog(@"本地摄像头%@",state);
}
//隐藏小窗口
-(void)smallSessionShowSetted{
    
    BOOL hidden=[self.smallSessionView boolValue];
    NSString *state;
    self.smallSessionView=@(!hidden);
    if (hidden) {
         state=@"隐藏了小窗口";
    }else{
        state=@"显示了小窗口";
    }
    NSLog(@"%@",state);
}
//挂断
-(void)sessionComplete{
    NSLog(@"用户挂断了.......");
    NSString *haltType=nil;
    if ([self.showingView integerValue]==ViewTypeAsession||[self.showingView integerValue]==ViewTypeVsession) {
            haltType=@"endsession";
    }else{
        haltType=@"refusesession";
    }
    [self.imService haltSession:haltType];
}
//接听
-(void)answer{
    NSLog(@"用户接听了   视频：%@",self.localCanVideo);
    self.localSessionView=[self.imService getCametaViewLocal];
    [[self.localSessionView.layer sublayers][0] setFrame:[UIScreen mainScreen].bounds];
    self.isPeerLarge=@(YES);
    [self.imService answer:[self.localCanVideo boolValue]];
}
//隐藏拨号盘（包括通话所有界面）
-(void)hideDialingSessionView{
    self.modelService.showSessinView=@(NO);
    
}
-(void)dial:(NSString*)itel useVideo:(BOOL)useVideo{
    NSLog(@"开始拨打:%@  是否视频:%d",itel,useVideo);
    [self setUser:itel];
    
    if (useVideo) {
        
        self.localSessionView=[self.imService getCametaViewLocal];
        [[self.localSessionView.layer sublayers][0] setFrame:[UIScreen mainScreen].bounds];
        self.isPeerLarge=@(YES);
        [self.imService vcall:itel];
    }
}
-(void)setUser:(NSString*)itel{
    ItelUser *user = [ItelUser userWithItel:itel];
    if (user) {
        self.peerNum=user.itelNum;
        self.peerName=user.nickName;
        self.peerArea=user.address;
        
    }else{
        self.peerNum=itel;
        self.peerName=@"陌生人";
        self.peerArea=@"";
    }
}
-(void)openScreen{
   
    NSLog(@"之前的PeerView:%@",self.peerSessionView);
        VideoRenderIosView *v=[[VideoRenderIosView alloc]init];
        self.peerSessionView=v;
    
    
  
   //self.peerSessionView.layer.frame=[UIScreen mainScreen].bounds ;
    self.peerSessionView.backgroundColor=[UIColor grayColor];
    
    [self.imService performSelector:@selector(openScreen:) withObject:self.peerSessionView afterDelay:2];
    NSLog(@"之后的PeerView:%@",self.peerSessionView);
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
@end
