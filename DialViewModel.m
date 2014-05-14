//
//  DialViewModel.m
//  DIalViewSence
//
//  Created by nsc on 14-4-24.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialViewModel.h"

@implementation DialViewModel
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
    
}
//接听
-(void)answer{
    NSLog(@"用户接听了   视频：%@",self.localCanVideo);
   
}
//隐藏拨号盘（包括通话所有界面）
-(void)hideDialingSessionView{
    self.modelService.showSessinView=@(NO);
}
-(void)dial:(NSString*)itel useVideo:(BOOL)useVideo{
    NSLog(@"开始拨打:%@  是否视频:%d",itel,useVideo);
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
@end
