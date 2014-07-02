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
#import "HTTPRequestBuilder+contact.h"
#import "DBService.h"
#import <UIImageView+AFNetworking.h>
#import "sdk.h"
@implementation DialViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imService=[IMService defaultService];
        __weak id weakSelf=self;
       [[RACObserve(self, imService.sessionType) map:^id(NSNumber *value) {
           __strong DialViewModel *strongSelf=weakSelf;
           if ([value integerValue]!=IMsessionTypeEdle) {
               strongSelf.modelService.showSessinView=@(YES);
           }
           
           if ([value integerValue]==IMsessionTypeCalling) {
               if ([strongSelf.imService.useVideo boolValue]) {
                   strongSelf.showingView=@(ViewTypeVCalling);
               }else{
                   strongSelf.showingView=@(ViewTypeACalling);
               }
           }else if ([value integerValue]==IMsessionTypeInSession){
               if ([strongSelf.imService.useVideo boolValue]) {
                    [strongSelf openScreen  ];
                   strongSelf.showingView=@(ViewTypeVsession);
                  
                   
               }else{
                   strongSelf.showingView=@(ViewTypeAsession);
               }
               
           }else if ([value integerValue]==IMsessionTypeAnsering){
               if ([strongSelf.imService.useVideo boolValue]) {
                   strongSelf.showingView=@(ViewTypeVAnsering);
               }else{
                   strongSelf.showingView=@(ViewTypeAAnsering);
               }
           }
           
            return value;
        }]subscribeNext:^(id x) {}];
        
       
        [[RACObserve(self, imService.sessionState) map:^id(id value) {
            __strong DialViewModel *strongSelf=weakSelf;
            strongSelf.connectionState=value;
            return value;
        }]subscribeNext:^(id x) {}];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(sessionCome:) name:@"sessionCome" object:nil];
        
        [RACObserve(self, imService.peerAccount) subscribeNext:^(NSString *x) {
            __strong DialViewModel *strongSelf=weakSelf;
            if (x.length) {
                [strongSelf loadPeerUser:x];
            }
          
        }];
        [RACObserve(self, peerUser) subscribeNext:^(ItelUser *x) {
            __strong DialViewModel *strongSelf=weakSelf;
            if (x) {
                strongSelf.peerName=x.nickName;
                strongSelf.peerHeader=x.imageurl;
                strongSelf.peerArea=x.address;
                strongSelf.peerNum=x.itelNum;
                if (x.address.length==0) {
                     strongSelf.peerArea=@"对方未设置地址";
                }
                
            }
            
        }];
    }
    return self;
}
-(void)loadPeerUser:(NSString*)peerItel{
    ItelUser *user=[ItelUser userWithItel:peerItel];
    if (!user) {
        [self searchUserInNet:peerItel];
    }else{
        self.peerUser=user;
    }
}
-(void)searchUserInNet:(NSString*)itel{
    [[self.requestBuilder searchOneUser:@{@"username":itel}]subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[x[@"code"]intValue];
        if (code==200) {
            NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
            ItelUser *user=[ItelUser userWithDictionary:x[@"data"] inContext:context];
            user.isFriend=@(NO);
            self.peerUser=user;
            [context save:nil];
        }else{
            [self netRequestFail:x];
        }
    }error:^(NSError *error) {
        
        self.busy=@(NO);
        [self netRequestError:error];
    }completed:^{
        self.busy=@(NO);
  

    }];
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
    [self.imService.avSdk switchCamera];
    NSLog(@"本地使用%@",state);
}

-(void)micSetted{
    
    BOOL isMicOn=[self.isMicOn boolValue];
     self.isMicOn=@(!isMicOn);
    NSString *state;
    if (isMicOn) {
        state=@"开启";
         [self.imService.avSdk unmute];
    }else{
        state=@"关闭";
        [self.imService.avSdk mute];
           }
   
    NSLog(@"本地麦克风%@",state);
}
-(void)soundSetted{
    BOOL isSoundOn=[self.isSoundOn boolValue];
    NSString *state;
       self.isSoundOn=@(!isSoundOn);
    if (!isSoundOn) {
        [self.imService.avSdk enableSpeaker];
        
        state=@"开启";
    }else{
        
        [self.imService.avSdk disableSpeaker];

        state=@"关闭";
    }
 
   
    
    
    NSLog(@"本地扬声器%@",state);
}
//本地摄像头
-(void)localCameraOnSetted{
    BOOL cameraOn=[self.isLocalCameraOn boolValue];
    NSString *state;
    self.isLocalCameraOn=@(!cameraOn);
    if (!cameraOn) {
         state=@"开启";
        [self.imService.avSdk showCam];
    }else{
        state=@"关闭";
        [self.imService.avSdk hideCam];
    }
    
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
-(void)answer:(NSNumber*)localCanVideo{
    if ([self.imService isAnsewering]) {
        return;
    }
    NSLog(@"用户接听了   视频：%@",self.localCanVideo);
    self.localCanVideo=localCanVideo;
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
    if ([self.imService.sessionType integerValue]!=IMsessionTypeEdle) {
        NSLog(@"用户忙 放弃拨打");
        return;
    }
    NSLog(@"开始拨打:%@  是否视频:%d",itel,useVideo);
    [self setUser:itel];
  
    
    if (useVideo) {
        
        self.localSessionView=[self.imService getCametaViewLocal];
        [[self.localSessionView.layer sublayers][0] setFrame:[UIScreen mainScreen].bounds];
        self.isPeerLarge=@(YES);
        [self.imService vcall:itel];
    }else{
        self.localSessionView=[self.imService getCametaViewLocal];
                [self.imService acall:itel];
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
    
    [self.imService performSelector:@selector(openScreen:) withObject:self.peerSessionView afterDelay:0.2];
    NSLog(@"之后的PeerView:%@",self.peerSessionView);
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
@end
