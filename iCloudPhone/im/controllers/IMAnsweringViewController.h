//
//  IMAnsweringViewController.h
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMManager.h"
@interface IMAnsweringViewController : UIViewController
- (IBAction)answerCall:(UIButton *)sender;
- (IBAction)refuseCall:(UIButton *)sender;
@property(nonatomic) NSNotification* callingNotify;
@property(nonatomic,weak) id<IMManager> manager;
@property (weak, nonatomic) IBOutlet UILabel *peerAccountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isVideoCallICONView;
@property (weak, nonatomic) IBOutlet UIView *answeringNameHUD;
@property (weak, nonatomic) IBOutlet UIView *answeringActionHUD;
@property (weak, nonatomic) IBOutlet UIView *inSessionNameHUD;
@property (weak, nonatomic) IBOutlet UIView *inSessionActionHUD;
@property (weak, nonatomic) IBOutlet UIView* cameraPreview;
@property (weak, nonatomic) IBOutlet UIButton* switchCameraBtn;
@property (weak, nonatomic) IBOutlet VideoRenderIosView *remoteRenderView;
- (IBAction)toggleHUD:(UITapGestureRecognizer *)sender;
- (IBAction)toggleMute:(UIButton *)sender;
- (IBAction)toggleSpeeker:(UIButton *)sender;
- (IBAction)toggleCam:(UIButton*)sender;
- (IBAction)togglePreviewCam:(UIButton*)sender;
- (IBAction)switchCamera:(UIButton *)sender;
- (IBAction)endSession:(UIButton *)sender;
@end
