//
//  IMInSessionViewController.h
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
#include "video_render_ios_view.h"
@interface IMInSessionViewController : UIViewController<UIGestureRecognizerDelegate>
@property(nonatomic,weak) id<IMManager> manager;
- (IBAction)endSession:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet VideoRenderIosView *remoteRenderView;
- (IBAction)toggleHUD:(UITapGestureRecognizer *)sender;
@property (weak, nonatomic) IBOutlet UIView *selfCamView; //小头像
@property(nonatomic,strong) NSNotification* inSessionNotify; //接收到的拨号信息
@property (weak, nonatomic) IBOutlet UIView *nameHUDView; //顶部名字
@property (weak, nonatomic) IBOutlet UIView *actionHUDView; //底部操作
@property (weak, nonatomic) IBOutlet UIButton *switchFrontAndBackCamBtn;
@property (weak, nonatomic) IBOutlet UIImageView* peerAvatar;
- (IBAction)toggleMute:(UIButton *)sender;
- (IBAction)toggleSpeeker:(UIButton *)sender;
- (IBAction)toggleCam:(UIButton*)sender;
- (IBAction)togglePreviewCam:(UIButton*)sender;
- (IBAction)switchCamera:(UIButton *)sender;
@end
