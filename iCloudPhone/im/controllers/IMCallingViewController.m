//
//  IMCallingViewController.m
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMCallingViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "ConstantHeader.h"
#import "IMInSessionViewController.h"
#import "ItelAction.h"
#import "UIImageView+AFNetworking.h"
#import "Area+toString.h"
#import "NSCAppDelegate.h"
static int soundCount;
@interface IMCallingViewController ()
@property(nonatomic) NSNotification* inSessionNotify;
@property(nonatomic) NSNumber* currentMode;
@property(nonatomic,weak) UIView* currentNameHUD;
@property(nonatomic,weak) UIView* currentActionHUD;
//状态
@property(nonatomic) BOOL isMute; //标志是否静音
@property(nonatomic) BOOL hideSelfCam; //标志是否隐藏小窗口
@property(nonatomic) BOOL hideCam; //标志是否关闭摄像头
@property(nonatomic) BOOL enableSpeaker; //标志是否开启扬声器
@property(nonatomic) MSWeakTimer* clock;
@end
enum modes
{
    inCallingMode  = 0, //拨号中
    inSessionMode // 通话中
};
@implementation IMCallingViewController
static int hasObserver = 0;
static void* modeIdentifier = (void*) &modeIdentifier;
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (hasObserver == 0) {
        [self addObserver:self forKeyPath:@"currentMode" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&modeIdentifier];
            hasObserver = 1;
        }
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotifications];
    [self setup];
    [self.manager sendCallingData ];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelCalling:(UIButton *)sender {
    sender.enabled = NO;
    NSDictionary* cancelCallParams =  @{
                                                                  kSrcAccount:[[self.manager myState] valueForKey:kMyAccount],
                                                                  kDestAccount:[[self.manager myState] valueForKey:kPeerAccount],
                                                                  kHaltType:kEndSession
                                                                  };
    [self.manager haltSession:cancelCallParams];
    
}

- (void) setup{
    ItelUser* peerUser =  [[ItelAction action] userInFriendBook:[[self.manager myState] valueForKey:kPeerAccount]];
    NSString* peerDisplayName = BLANK_STRING;
    if (!peerUser) {
        peerDisplayName = [[self.manager myState] valueForKey:kPeerAccount];
    }else{
        peerDisplayName = peerUser.nickName;
    }
    self.peerAccountLabel.text = [NSString stringWithFormat:@"%@ 拨号中...",peerDisplayName];
    self.PeerAvatarImageView.layer.cornerRadius = 10;
    self.PeerAvatarImageView.layer.masksToBounds = YES;
    
    [self.PeerAvatarImageView setImageWithURL:[NSURL URLWithString:peerUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    //开始拨号了。播放声音
    soundCount = 0;//给拨号音计数，响八次就可以结束
    //系统声音播放是一个异步过程。要循环播放则必须借助回调
    AudioServicesAddSystemSoundCompletion(DIALING_SOUND_ID,NULL,NULL,soundPlayCallback,NULL);
    AudioServicesPlaySystemSound(DIALING_SOUND_ID);
    self.currentMode = @(inCallingMode);


}

- (void) tearDown{
    //终止拨号音
    AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
    AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);
    [self removeNotifications];
    [((NSCAppDelegate*)[UIApplication sharedApplication].delegate).dialPanelWindow setHidden:YES];
}
-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoSession:) name:PRESENT_INSESSION_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupPreview:) name:OPEN_CAMERA_SUCCESS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionClosed:) name:END_SESSION_NOTIFICATION object:nil];
}
-(void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (hasObserver == 1) {
        [self removeObserver:self forKeyPath:@"currentMode" context:&modeIdentifier];
        hasObserver =0;
    }
}
//循环播放声音
void soundPlayCallback(SystemSoundID soundId, void *clientData){
    if (soundCount>9) {
        AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
        AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);
    }
    soundCount++;
    AudioServicesPlaySystemSound(DIALING_SOUND_ID);
}

- (void) sessionClosed:(NSNotification*) notify{
    [self tearDown];
    [self.manager dismissDialRelatedPanel] ;
}

#pragma mark - HANDLER
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (context == modeIdentifier) {
        NSNumber* newState =(NSNumber*) [change valueForKey:@"new"];
        NSNumber* oldState = (NSNumber*)[change valueForKey:@"old"];
        switch ([newState intValue]) {
            case inCallingMode:
            {
                [self presentCallingModeHUD];
                if ([oldState isEqual:@(inSessionMode)]) {
                    [self tearDownInSessionState];
                }
            }
                break;
            case inSessionMode:
            {
                [self presentSessionModeHUD];
                [self setupInSessionState];
            }
                break;
            default:
                break;
        }
    }
}
- (void) presentCallingModeHUD{

    [self.inSessionNameHUD setHidden:YES];
    [self.inSessionActionHUD setHidden:YES];
    [self.callingNameHUD setHidden:NO];
    [self.callingActionHUD setHidden:NO];
    self.currentNameHUD = self.callingNameHUD;
    self.currentActionHUD = self.callingActionHUD;
    [self.switchCameraBtn setHidden:YES];
}
- (void) presentSessionModeHUD{
    [self.callingNameHUD setHidden:YES];
    [self.callingActionHUD setHidden:YES];
    [self.inSessionNameHUD setHidden:NO];
    [self.inSessionActionHUD setHidden:NO];
    self.currentNameHUD = self.inSessionNameHUD;
    self.currentActionHUD = self.inSessionActionHUD;
    [self.switchCameraBtn setHidden:YES];
    
}
- (void)toggleHUD:(UITapGestureRecognizer *)sender{
    if ([self.currentNameHUD isHidden]) {
        [self.currentNameHUD setHidden:NO];
        [self.switchCameraBtn setHidden:YES];
    }else{
        [self.currentNameHUD setHidden:YES];
        [self.switchCameraBtn setHidden:NO];
    }
    if ([self.currentActionHUD isHidden]) {
        [self.currentActionHUD  setHidden:NO];
    }else{
        [self.currentActionHUD setHidden:YES];
    }
}
- (void) setupPreview:(NSNotification*) notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPEN_CAMERA_SUCCESS_NOTIFICATION object:Nil];
    CGRect previewSize = CGRectMake(0, 0, self.cameraPreview.bounds.size.width, self.cameraPreview.bounds.size.height);
    UIView* preview = (UIView*) [notify.userInfo valueForKey:@"preview"];
    [preview setFrame:previewSize];
    [[preview.layer sublayers][0] setFrame:previewSize];
    [self.cameraPreview addSubview:preview];
}
- (void)intoSession:(NSNotification*) notify{
    self.inSessionNotify = notify;
    self.currentMode = @(inSessionMode);
    if (0 == [self.manager openScreen:self.remoteRenderView] ) {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            [self resizePreviewInSession];
        } completion:^(BOOL finished){
            [self decoratePreview];
        }];
    }


}
- (void) resizePreviewInSession{
    //调整预览窗框大小
    CGRect smallSize =  CGRectMake(0, 0, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3);
    [self.cameraPreview setFrame:CGRectMake(FULL_SCREEN.size.width*.7, FULL_SCREEN.size.height*.7, FULL_SCREEN.size.width*.3, FULL_SCREEN.size.height*.3)];
    if ([[self.cameraPreview subviews] count]) {
        [self.cameraPreview setHidden:NO];
        [[((UIView*)[self.cameraPreview subviews][0]).layer sublayers][0] setFrame:smallSize];
    }else{
        [self.cameraPreview setHidden:YES];
    }
}
- (void) decoratePreview{
    //小窗口要个边框好看些
    self.cameraPreview.layer.borderColor = [[UIColor grayColor] CGColor];
    self.cameraPreview.layer.borderWidth = .5f;
    self.cameraPreview.layer.masksToBounds = YES;
}
- (void) setupInSessionState{
    //终止拨号音
    AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
    AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);
    //通话过程中,禁止锁屏
    [self.manager lockScreenForSession];
    //定时器用于显示通话时长
    [self.clock invalidate];
    self.clock = [MSWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("com.itelland.clock_queue", DISPATCH_QUEUE_CONCURRENT)];
    // 设置下标志位状态
    self.isMute = NO; // 初始不是静音的
    self.hideSelfCam = NO; //初始显示小窗口
    self.hideCam = NO; //初始开启摄像头
    self.enableSpeaker = YES; //初始关闭扬声器
    [self.manager enableSpeaker];
//    self.switchFrontAndBackCamBtn.hidden = YES; //初始隐藏交换摄像头按钮
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
    
    ((UILabel*)[self.inSessionNameHUD viewWithTag:1]).text= nickName;
    ((UILabel*)[self.inSessionNameHUD viewWithTag:2]).text= itelNum;
    ((UILabel*)[self.inSessionNameHUD viewWithTag:4]).text = address;
//    [self.peerAvatar setImageWithURL:[NSURL URLWithString: peerUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    if ([self.manager isVideoCall]) {
//        [self.peerAvatar setHidden:YES ];
    }else{
//        [self.peerAvatar setHidden:NO];
    }
}

- (void) tearDownInSessionState{
    [self.manager unlockScreenForSession];
    [self.clock invalidate];
    self.clock = nil;
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
        self.cameraPreview.hidden = NO;
        self.hideSelfCam = NO;
        sender.selected = NO;
    }else{
        self.cameraPreview.hidden = YES;
        self.hideSelfCam = YES;
        sender.selected = YES;
    }
}

- (IBAction)switchCamera:(UIButton *)sender {
    sender.enabled = NO;
    [self.manager switchCamera];
    sender.enabled = YES;
}
- (IBAction)endSession:(UIButton *)sender {
    sender.enabled = NO;
    //构造通话结束信令
    NSMutableDictionary* endSessionDataMut = [self.inSessionNotify.userInfo mutableCopy];
    [endSessionDataMut addEntriesFromDictionary:@{
                                                  kHaltType:kEndSession
                                                  }];
    
    //终止会话
    [self.manager haltSession:endSessionDataMut];
}

- (void) refresh{
    dispatch_async(dispatch_get_main_queue(), ^{
        ((UILabel*)[self.inSessionNameHUD viewWithTag:3]).text = [IMUtils secondsToTimeFormat:[self.manager checkDuration]] ;
    });
    
}
@end
