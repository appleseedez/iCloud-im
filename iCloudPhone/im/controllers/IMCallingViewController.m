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
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
static int soundCount;
@interface IMCallingViewController ()
@property(nonatomic) NSNotification* inSessionNotify;
@end

@implementation IMCallingViewController

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //监听 "PRESENT_INSESSION_VIEW_NOTIFICATION"// 通知加载“通话中界面”
    [self registerNotifications];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self tearDown];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelCalling:(UIButton *)sender {
    sender.enabled = NO;
    NSDictionary* cancelCallParams =  @{
                                                                  SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:[[self.manager myState] valueForKey:kMyAccount],
                                                                  SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:[[self.manager myState] valueForKey:kPeerAccount],
                                                                  SESSION_HALT_FIELD_TYPE_KEY:SESSION_HALT_FILED_ACTION_END
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
    self.peerAccountLabel.text = [NSString stringWithFormat:@"呼叫用户 %@",peerDisplayName];
    self.PeerAvatarImageView.layer.cornerRadius = 10;
    self.PeerAvatarImageView.layer.masksToBounds = YES;
    
    [self.PeerAvatarImageView setImageWithURL:[NSURL URLWithString:peerUser.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    //开始拨号了。播放声音
    soundCount = 0;//给拨号音计数，响八次就可以结束
    //系统声音播放是一个异步过程。要循环播放则必须借助回调
    AudioServicesAddSystemSoundCompletion(DIALING_SOUND_ID,NULL,NULL,soundPlayCallback,NULL);
    AudioServicesPlaySystemSound(DIALING_SOUND_ID);

}

- (void) tearDown{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //终止拨号音
    AudioServicesRemoveSystemSoundCompletion(DIALING_SOUND_ID);
    AudioServicesDisposeSystemSoundID(DIALING_SOUND_ID);
    [self removeNotifications];
}
-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(intoSession:) name:PRESENT_INSESSION_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionClosed:) name:END_SESSION_NOTIFICATION object:nil];
}
-(void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HANDLER
- (void)intoSession:(NSNotification*) notify{
    self.inSessionNotify = notify;
    [self performSegueWithIdentifier:@"sessionRequestAcceptedByPeerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"sessionRequestAcceptedByPeerSegue"]) {
        IMInSessionViewController* insessionController = (IMInSessionViewController*)segue.destinationViewController;
        IMCallingViewController* target = (IMCallingViewController*) sender;
        insessionController.manager = target.manager;
        insessionController.inSessionNotify = target.inSessionNotify;
    }
}
@end
