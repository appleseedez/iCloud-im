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
//#import "CMOpenALSoundManager.h"
//static int soundCount;
@interface IMCallingViewController ()<AVAudioPlayerDelegate>
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
//@property (nonatomic, strong) CMOpenALSoundManager *soundMgr;
@property(nonatomic) AVAudioPlayer* soudMgr;
@end
enum modes
{
    inCallingMode  = 0, //拨号中
    inSessionMode // 通话中
};
//enum mySoundIds {
//	AUDIOEFFECT
//};
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
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:@"callingSound" ofType:@"m4a"]];
        self.soudMgr = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        if (self.soudMgr) {
            self.soudMgr.numberOfLoops = -1;
            self.soudMgr.delegate = self;
        }
        
        [[AVAudioSession sharedInstance] setDelegate: self];
        
        NSError *setCategoryError = nil;
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error: &setCategoryError];
        if (setCategoryError) NSLog(@"Error setting category! %d", setCategoryError.code);
    }
    return self;
}
- (void)dealloc{
    [self.soudMgr stop];
    self.soudMgr.delegate = nil;
    self.soudMgr = nil;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];


}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerNotifications];
    self.currentMode = @(inCallingMode);

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.PeerAvatarImageView.layer.cornerRadius = 10;
    self.PeerAvatarImageView.layer.masksToBounds = YES;
    [self.soudMgr play];
}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption begin. Updating UI for new state");
    [p pause];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption ended. Resuming playback");
    if ([self.currentMode intValue] == inSessionMode) {
        [p stop];
    }else{
        [p play];
    }
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
- (void) setup:(NSNotification*) notify{
    [self setup];
    [self.manager sendCallingData ];
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
//    self.PeerAvatarImageView.layer.cornerRadius = 10;
//    self.PeerAvatarImageView.layer.masksToBounds = YES;
    
    [self.PeerAvatarImageView setImageWithURL:[NSURL URLWithString:peerUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    
    if ([self.manager isVideoCall]) {
        self.isVideoIconView.image = [UIImage imageNamed:@"videoCall_ico"];
    }else{
        self.isVideoIconView.image = [UIImage imageNamed:@"voiceCall_ico"];
    }



}
- (void) closeRemoteForRelayTransport:(NSNotification*) notify{
    [self.cameraPreview setHidden:YES];
}
- (void) tearDown{
    [self.soudMgr stop];
    [self removeNotifications];
}
-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoSession:) name:PRESENT_INSESSION_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeRemoteForRelayTransport:) name:CLOSE_REMOTE_VIEW_FOR_RELAY_TRANSPORT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup:) name:PEER_FOUND_NOTIFICATION object:nil];
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
////循环播放声音
//void soundPlayCallback(SystemSoundID soundId, void *clientData){
//    if (soundCount>9) {
//        AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
//        AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);
//    }
//    soundCount++;
//    AudioServicesPlaySystemSound(DIALING_SOUND_ID);
//}

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
    [self.inSessionVoiceActionHUD setHidden:YES];
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
    if ([self.manager isVideoCall]) {
        [self.inSessionActionHUD setHidden:NO];
        [self.inSessionVoiceActionHUD setHidden:YES];
        self.currentActionHUD = self.inSessionActionHUD;
    }else{
        [self.inSessionVoiceActionHUD setHidden:NO];
        [self.inSessionActionHUD setHidden:YES];
        self.currentActionHUD = self.inSessionVoiceActionHUD;
    }
    self.currentNameHUD = self.inSessionNameHUD;
    [self.switchCameraBtn setHidden:YES];
    
}
- (void)toggleHUD:(UITapGestureRecognizer *)sender{
    if ([self.currentNameHUD isHidden]) {
        [self.currentNameHUD setHidden:NO];
        [self.switchCameraBtn setHidden:YES];
    }else{
        [self.currentNameHUD setHidden:YES];
        if ([self.manager isVideoCall]) {
            [self.switchCameraBtn setHidden:NO];
        }else{
            [self.switchCameraBtn setHidden:YES];
        }
        
    }
    if ([self.currentActionHUD isHidden]) {
        [self.currentActionHUD  setHidden:NO];
    }else{
        [self.currentActionHUD setHidden:YES];
    }
}
- (void) setupPreview:(NSNotification*) notify{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:OPEN_CAMERA_SUCCESS_NOTIFICATION object:Nil];
    CGRect previewSize = CGRectMake(0, 0, self.cameraPreview.bounds.size.width, self.cameraPreview.bounds.size.height);
    UIView* preview = (UIView*) [notify.userInfo valueForKey:@"preview"];
    [preview setFrame:previewSize];
    [[preview.layer sublayers][0] setFrame:previewSize];
    [self.cameraPreview addSubview:preview];
    [self.cameraPreview setHidden:NO];
}
- (void)intoSession:(NSNotification*) notify{
    if ([self.soudMgr isPlaying]) {
        [self.soudMgr pause];
    }
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
//    AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
//    AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);

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
        self.isVideoIconView.image = [UIImage imageNamed:@"videoCall_ico"];
    }else{
        self.isVideoIconView.image = [UIImage imageNamed:@"voiceCall_ico"];
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
