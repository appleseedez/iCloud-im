//
//  IMCallingViewController.h
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
@interface IMCallingViewController : UIViewController<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *peerAccountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *PeerAvatarImageView;
@property (weak, nonatomic) IBOutlet UIView *callingNameHUD;
@property (weak, nonatomic) IBOutlet UIView *callingActionHUD;
@property (weak, nonatomic) IBOutlet UIView *inSessionNameHUD;
@property (weak, nonatomic) IBOutlet UIView *inSessionActionHUD;
@property (weak, nonatomic) IBOutlet UIView* cameraPreview;
@property (weak, nonatomic) IBOutlet VideoRenderIosView *remoteRenderView;
- (IBAction)cancelCalling:(UIButton *)sender;
- (IBAction)toggleHUD:(UITapGestureRecognizer *)sender;
- (IBAction)toggleMute:(UIButton *)sender;
- (IBAction)toggleSpeeker:(UIButton *)sender;
- (IBAction)toggleCam:(UIButton*)sender;
- (IBAction)togglePreviewCam:(UIButton*)sender;
- (IBAction)switchCamera:(UIButton *)sender;
- (IBAction)endSession:(UIButton *)sender;
@property(nonatomic,weak) id<IMManager> manager;
@end
