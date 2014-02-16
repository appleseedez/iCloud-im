//
//  IMInSessionViewController.m
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMInSessionViewController.h"
#import "ItelAction.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "Area+toString.h"
@interface IMInSessionViewController ()
@property(nonatomic) BOOL hideHUD; //标志是否隐藏控制面板
@property(nonatomic) BOOL isMute; //标志是否静音
@property(nonatomic) BOOL hideSelfCam; //标志是否隐藏小窗口
@property(nonatomic) BOOL hideCam; //标志是否关闭摄像头
@property(nonatomic) BOOL enableSpeaker; //标志是否开启扬声器
@property(nonatomic) MSWeakTimer* clock;

@end

@implementation IMInSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![self.manager isVideoCall]) {
        self.remoteRenderView = nil;
        
    }
    //开启视频窗口，调整摄像头
    [self.view sendSubviewToBack:self.remoteRenderView];
    [self performSelector:@selector(openScreen) withObject:Nil afterDelay:2];
}

- (void) openScreen{
    [self.manager openScreen:self.remoteRenderView localView:self.selfCamView];
}
- (void)viewDidAppear:(BOOL)animated{
    [self setup];
}
- (void) viewWillDisappear:(BOOL)animated{
    [self tearDown];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setup{
    [self registerNotifications];
    //通话过程中,禁止锁屏
    [self.manager lockScreenForSession];
    //定时器用于显示通话时长
    [self.clock invalidate];
    self.clock = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("com.itelland.clock_queue", DISPATCH_QUEUE_CONCURRENT)];
    //小窗口要个边框好看些
    self.selfCamView.layer.borderWidth = 1.0f;
    self.selfCamView.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.selfCamView.layer.masksToBounds = YES;
    self.selfCamView.layer.cornerRadius = 1.f;
    // 设置下标志位状态
    self.isMute = NO; // 初始不是静音的
    self.hideHUD = NO; //初始显示控制板
    self.hideSelfCam = NO; //初始显示小窗口
    self.hideCam = NO; //初始开启摄像头
    self.enableSpeaker = YES; //初始关闭扬声器
    [self.manager enableSpeaker];
    self.switchFrontAndBackCamBtn.hidden = YES; //初始隐藏交换摄像头按钮
    [self performSelector:@selector(toggleHUD:) withObject:nil afterDelay:3];
    // 设置好名字版
    
    ItelUser* peerUser = [[ItelAction action] userInFriendBook:[[self.inSessionNotify userInfo] valueForKey:@"destaccount"]];
    NSString* nickName = BLANK_STRING;
    NSString* itelNum = BLANK_STRING;
    NSString* address = BLANK_STRING;
    
    if (peerUser) {
        nickName = peerUser.nickName;
        itelNum = peerUser.itelNum;
        address = [Area idForArea:peerUser.address].toString;
    }else{
        nickName = @"陌生人";
        itelNum =[[self.inSessionNotify userInfo] valueForKey:@"destaccount"];
    }
    
    ((UILabel*)[self.nameHUDView viewWithTag:1]).text= nickName;
    ((UILabel*)[self.nameHUDView viewWithTag:2]).text= itelNum;
    ((UILabel*)[self.nameHUDView viewWithTag:4]).text = address;
    [self.peerAvatar setImageWithURL:[NSURL URLWithString: peerUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    if ([self.manager isVideoCall]) {
        [self.peerAvatar setHidden:YES ];
    }else{
        [self.peerAvatar setHidden:NO];
    }
}
- (void) refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        ((UILabel*)[self.nameHUDView viewWithTag:3]).text = [IMUtils secondsToTimeFormat:[self.manager checkDuration]] ;
    });
    
}
- (void) tearDown{
    [self removeNotifications];
    [self.manager unlockScreenForSession];
    [self.clock invalidate];
    self.clock = nil;
    
}
- (void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionClosed:) name:END_SESSION_NOTIFICATION object:nil];
}
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) sessionClosed:(NSNotification*) notify{
    //关闭视频窗口
    if (self.remoteRenderView) {
        [self.remoteRenderView removeFromSuperview];
    }
    if (self.navigationController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (IBAction)endSession:(UIButton *)sender {
    sender.enabled = NO;
    //构造通话结束信令
    NSMutableDictionary* endSessionDataMut = [self.inSessionNotify.userInfo mutableCopy];
    [endSessionDataMut addEntriesFromDictionary:@{
                                                  SESSION_HALT_FIELD_TYPE_KEY:SESSION_HALT_FILED_ACTION_END
                                                  }];
    
    //终止会话
    [self.manager haltSession:endSessionDataMut];
}
- (IBAction)toggleHUD:(UITapGestureRecognizer *)sender {
// 点击会让HUD收缩
    if (!self.hideHUD) {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.nameHUDView.center= CGPointMake(self.nameHUDView.center.x, self.nameHUDView.center.y-self.nameHUDView.bounds.size.height-STATUS_BAR_HEIGHT);
            self.actionHUDView.center = CGPointMake(self.actionHUDView.center.x, self.actionHUDView.center.y+ self.actionHUDView.bounds.size.height);
        } completion:nil];
        self.hideHUD = YES;
        self.switchFrontAndBackCamBtn.hidden = NO;
    }else{
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.nameHUDView.center= CGPointMake(self.nameHUDView.center.x, self.nameHUDView.center.y+self.nameHUDView.bounds.size.height+STATUS_BAR_HEIGHT);
            self.actionHUDView.center = CGPointMake(self.actionHUDView.center.x, self.actionHUDView.center.y- self.actionHUDView.bounds.size.height);
        } completion:nil];
        self.hideHUD = NO;
        self.switchFrontAndBackCamBtn.hidden = YES;
    }
}
- (IBAction)toggleMute:(UIButton *)sender {
    if (self.isMute) {
        [self.manager unmute];
        self.isMute=NO;
        sender.selected = NO;
    }else{
        [self.manager mute];
        self.isMute = YES;
        sender.selected = YES;
    }
}

- (IBAction)toggleSpeeker:(UIButton *)sender {
    if (self.enableSpeaker) {
        [self.manager disableSpeaker];
        self.enableSpeaker = NO;
        sender.selected = NO;
    }else{
        [self.manager enableSpeaker];
        self.enableSpeaker = YES;
        sender.selected = YES;
    }
}

- (IBAction)toggleCam:(UIButton*)sender {
    if (self.hideCam) {
        [self.manager showCam];
//        [self.remoteRenderView setHidden:NO];
        self.hideCam = NO;
        sender.selected = NO;
    }else{
        [self.manager hideCam];
//        [self.remoteRenderView setHidden:YES];
        self.hideCam = YES;
        sender.selected = YES;
    }
}

- (IBAction)togglePreviewCam:(UIButton*)sender {
    if (self.hideSelfCam) {
        self.selfCamView.hidden = NO;
        self.hideSelfCam = NO;
        sender.selected = NO;
    }else{
        self.selfCamView.hidden = YES;
        self.hideSelfCam = YES;
        sender.selected = YES;
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    sender.enabled = NO;
    [self.manager switchCamera];
    sender.enabled = YES;
}
@end
