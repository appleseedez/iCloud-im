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
@property (weak, nonatomic) IBOutlet UIView *selfCamView;
@property(nonatomic,strong) NSNotification* inSessionNotify;
@property (weak, nonatomic) IBOutlet UIView *nameHUDView;
@property (weak, nonatomic) IBOutlet UIView *actionHUDView;
@end
