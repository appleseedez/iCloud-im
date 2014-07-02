//
//  VideoSessionViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "VideoSessionViewController.h"
#import "DialViewModel.h"
@interface VideoSessionViewController ()
@property (weak, nonatomic) IBOutlet UIView *mainSessionView;
@property (weak, nonatomic) IBOutlet UIView *secondarySessionView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlView;
@property (weak, nonatomic) IBOutlet UIView *topControlView;
@property (strong, nonatomic) NSNumber *showControlView;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIButton *btnSound;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnEndSession;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (weak, nonatomic) IBOutlet UIButton *btnSmallSessionView;
@end

@implementation VideoSessionViewController


static float TopShow;
static float TopHide;
static float BottomShow;
static float BottomHide;
- (void)viewDidLoad
{
    [super viewDidLoad];
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        
    }else{
        self.view.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
   
    [self.secondarySessionView.layer setBorderWidth:2];
    [self.secondarySessionView.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.showControlView=@(1);
    TopShow = self.topControlView.center.y;
    BottomShow=self.bottomControlView.center.y;
    BottomHide =self.bottomControlView.center.y+123;
   TopHide=TopShow-59;
    UITapGestureRecognizer *HideControleRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animation:)];
    [self.view addGestureRecognizer:HideControleRecognizer];
    UITapGestureRecognizer *changeSessionViewRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changePeerViewToLocal)];
    [self.secondarySessionView addGestureRecognizer:changeSessionViewRecognizer];
    
    __weak id weakSelf=self;
    
    //监听 隐藏 控制面板
    [RACObserve(self, showControlView) subscribeNext:^(NSNumber *showControleView) {
        __strong VideoSessionViewController *strongSelf=weakSelf;
        [UIView animateWithDuration:0.3 animations:^{
            if ([showControleView boolValue]) {
                strongSelf.topControlView.center=CGPointMake(160, TopShow);
                strongSelf.bottomControlView.center=CGPointMake(160, BottomShow);
            }else{
                strongSelf.topControlView.center=CGPointMake(160, TopHide);
                strongSelf.bottomControlView.center=CGPointMake(160, BottomHide);
            }
        }];
        
    }];
    //监听 交换窗口
    [RACObserve(self.viewModel, isPeerLarge) subscribeNext:^(NSNumber *x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        BOOL isPeerLarge=[x boolValue];
        [UIView beginAnimations:@"" context:nil];
        if (isPeerLarge) {
            
            strongSelf.viewModel.peerSessionView.frame=strongSelf.mainSessionView.bounds;
            [strongSelf.mainSessionView addSubview:strongSelf.viewModel.peerSessionView];
            strongSelf.viewModel.localSessionView.frame=strongSelf.secondarySessionView.bounds;
            [strongSelf.secondarySessionView addSubview:strongSelf.viewModel.localSessionView];
        }else{
            strongSelf.viewModel.peerSessionView.frame=strongSelf.secondarySessionView.bounds;
            [strongSelf.secondarySessionView addSubview:strongSelf.viewModel.peerSessionView];
            strongSelf.viewModel.localSessionView.frame=strongSelf.mainSessionView.bounds;
            
            [strongSelf.mainSessionView addSubview:strongSelf.viewModel.localSessionView];
            
        }
        ((CALayer*)strongSelf.viewModel.localSessionView.layer.sublayers[0]).frame=strongSelf.viewModel.localSessionView.bounds;
       // strongSelf.viewModel.peerSessionView.backgroundColor=[UIColor redColor];
      //  NSLog(@"peerSessionView的subviews:%@",strongSelf.viewModel.peerSessionView.subviews);
        [UIView commitAnimations];
    }];
    // 监听 麦克风
    
      [RACObserve(self, viewModel.isMicOn) subscribeNext:^(NSNumber *x) {
           __strong VideoSessionViewController *strongSelf=weakSelf;
          BOOL micOn=[x boolValue];
          if (micOn) {
              [strongSelf.btnMic setBackgroundImage:[UIImage imageNamed:@"btn_mic_on"] forState:UIControlStateNormal];
          }else{
              [strongSelf.btnMic setBackgroundImage:[UIImage imageNamed:@"btn_mic_off"] forState:UIControlStateNormal];
          }
      }];
    //mic点击事件
    [[self.btnMic rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel micSetted];
    }];
    //监听 扬声器
    
      [RACObserve(self, viewModel.isSoundOn) subscribeNext:^(NSNumber *x) {
           __strong VideoSessionViewController *strongSelf=weakSelf;
          BOOL soundOn=[x boolValue];
          if (soundOn) {
              [strongSelf.btnSound setBackgroundImage:[UIImage imageNamed:@"btn_outSound_on"] forState:UIControlStateNormal];
          }else{
              [strongSelf.btnSound setBackgroundImage:[UIImage imageNamed:@"btn_outSound_off"] forState:UIControlStateNormal];
          }

      }];
    //扬声器点击事件
    [[self.btnSound rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel soundSetted];
    }];
    
    //监听 本地摄像头开关
     [RACObserve(self, viewModel.isLocalCameraOn) subscribeNext:^(NSNumber *x) {
          __strong VideoSessionViewController *strongSelf=weakSelf;
         BOOL cameraOn=[x boolValue];
         if (cameraOn) {
             [strongSelf.btnCamera setBackgroundImage:[UIImage imageNamed:@"btn_localCamera_on"] forState:UIControlStateNormal];
         }else{
             [strongSelf.btnCamera setBackgroundImage:[UIImage imageNamed:@"btn_localCamera_off"] forState:UIControlStateNormal];
         }

     }];
    //本地摄像头 设置事件
    [[self.btnCamera rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel localCameraOnSetted];
    }];
    
    //监听 隐藏小窗口
    [RACObserve(self, viewModel.smallSessionView) subscribeNext:^(NSNumber *x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        BOOL hideSmall=[x boolValue];
    
        if (hideSmall) {
            [strongSelf.btnSmallSessionView setBackgroundImage:[UIImage imageNamed:@"btn_peerCamera_on"] forState:UIControlStateNormal];
            strongSelf.secondarySessionView.alpha=1;
        }else{
            [strongSelf.btnSmallSessionView setBackgroundImage:[UIImage imageNamed:@"btn_peerCamera_off"] forState:UIControlStateNormal];
            strongSelf.secondarySessionView.alpha=0;
        }
        
    }];
    // 隐藏小窗口设置事件
    [[self.btnSmallSessionView rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel smallSessionShowSetted];
    }];
    //挂断
    [[self.btnEndSession rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         __strong VideoSessionViewController *strongSelf=weakSelf;
        
        [strongSelf.viewModel sessionComplete];
    }];
    
    // 系统时间显示
     [RACObserve(self, viewModel.systemTime) subscribeNext:^(NSString *x) {
          __strong VideoSessionViewController *strongSelf=weakSelf;
         dispatch_async(dispatch_get_main_queue(), ^{
         strongSelf.lbTime.text=x;
         });
     }];
    ((CALayer*)self.viewModel.localSessionView.layer.sublayers[0]).frame=self.viewModel.localSessionView.bounds;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   // [self clearSessionView:self.mainSessionView except:nil];
    //[self clearSessionView:self.secondarySessionView except:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.viewModel.isPeerLarge=@(YES);
    self.view.userInteractionEnabled=NO;
    [self.view performSelector:@selector(setUserInteractionEnabled:) withObject:@(YES) afterDelay:0.5];
}
-(void)animation:(UITapGestureRecognizer*)gesture{
    bool show=[self.showControlView boolValue];
    self.showControlView=@(!show);
}
- (IBAction)changeCamera:(id)sender {
    [self.viewModel changeCamera];
}
-(void)changePeerViewToLocal{
    BOOL change=[self.viewModel.isPeerLarge boolValue];
    self.viewModel.isPeerLarge=@(!change);

}
-(void)clearSessionView:(UIView*)sessionView except:(UIView*)currView{
    for (UIView *v in sessionView.subviews ) {
        if (v!=currView) {
            [v removeFromSuperview];
        }
        
    }
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
