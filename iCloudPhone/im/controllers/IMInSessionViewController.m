//
//  IMInSessionViewController.m
//  im
//
//  Created by Pharaoh on 13-11-26.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMInSessionViewController.h"

@interface IMInSessionViewController ()
@property(nonatomic) BOOL hideHUD;
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
    //开启视频窗口，调整摄像头
    [self.view sendSubviewToBack:self.remoteRenderView];
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
    [self.manager lockScreenForSession];
}

- (void) tearDown{
    [self removeNotifications];
    [self.manager unlockScreenForSession];
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)endSession:(UIButton *)sender {
    //构造通话结束信令
    NSMutableDictionary* endSessionDataMut = [self.inSessionNotify.userInfo mutableCopy];
    [endSessionDataMut addEntriesFromDictionary:@{
                                                  SESSION_HALT_FIELD_TYPE_KEY:SESSION_HALT_FILED_ACTION_END
                                                  }];
    
    NSLog(@"通话中界面的业务数据：%@",endSessionDataMut);
    //终止会话
    [self.manager haltSession:endSessionDataMut];
    [self sessionClosed:nil];
}
- (IBAction)toggleHUD:(UITapGestureRecognizer *)sender {
// 点击会让HUD收缩
    if (!self.hideHUD) {
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.nameHUDView.center= CGPointMake(self.nameHUDView.center.x, self.nameHUDView.center.y-self.nameHUDView.bounds.size.height-STATUS_BAR_HEIGHT);
            self.actionHUDView.center = CGPointMake(self.actionHUDView.center.x, self.actionHUDView.center.y+ self.actionHUDView.bounds.size.height);
        } completion:nil];
        self.hideHUD = YES;
    }else{
        [UIView animateWithDuration:.3 delay:.2 options:UIViewAnimationCurveEaseInOut animations:^{
            self.nameHUDView.center= CGPointMake(self.nameHUDView.center.x, self.nameHUDView.center.y+self.nameHUDView.bounds.size.height+STATUS_BAR_HEIGHT);
            self.actionHUDView.center = CGPointMake(self.actionHUDView.center.x, self.actionHUDView.center.y- self.actionHUDView.bounds.size.height);
        } completion:nil];
        self.hideHUD = NO;
    }
}
@end
