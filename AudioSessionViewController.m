//
//  AudioSessionViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AudioSessionViewController.h"
#import "DialViewModel.h"
@interface AudioSessionViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomControlView;
@property (weak, nonatomic) IBOutlet UIView *topControlView;
@property (strong, nonatomic) NSNumber *showControlView;
@property (weak, nonatomic) IBOutlet UIButton *btnMic;
@property (weak, nonatomic) IBOutlet UIButton *btnSound;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerName;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerItel;

@property (weak, nonatomic) IBOutlet UIButton *btnEndSession;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;

@end

@implementation AudioSessionViewController
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
    [self setHeaderImage];
    self.showControlView=@(1);
    TopShow = self.topControlView.center.y;
    BottomShow=self.bottomControlView.center.y;
    BottomHide =self.bottomControlView.center.y+62;
    TopHide=TopShow-70;
    UITapGestureRecognizer *HideControleRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(animation:)];
    [self.view addGestureRecognizer:HideControleRecognizer];
   __weak id weakSelf=self;
    //监听 隐藏 控制面板
    [RACObserve(self, showControlView) subscribeNext:^(NSNumber *showControleView) {
         __strong AudioSessionViewController *strongSelf=weakSelf;
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
    // 监听 麦克风
    
    [RACObserve(self, viewModel.isMicOn) subscribeNext:^(NSNumber *x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        BOOL micOn=[x boolValue];
        if (micOn) {
            [strongSelf.btnMic setImage:[UIImage imageNamed:@"btn_mic_on"] forState:UIControlStateNormal];
        }else{
            [strongSelf.btnMic setImage:[UIImage imageNamed:@"btn_mic_off"] forState:UIControlStateNormal];
        }
    }];
    //mic点击事件
    [[self.btnMic rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel micSetted];
    }];
    //监听 扬声器
    
    [RACObserve(self, viewModel.isSoundOn) subscribeNext:^(NSNumber *x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        BOOL soundOn=[x boolValue];
        if (soundOn) {
            [strongSelf.btnSound setImage:[UIImage imageNamed:@"btn_outSound_on"] forState:UIControlStateNormal];
        }else{
            [strongSelf.btnSound setImage:[UIImage imageNamed:@"btn_outSound_off"] forState:UIControlStateNormal];
        }
        
    }];
    //扬声器点击事件
    [[self.btnSound rac_signalForControlEvents:UIControlEventTouchDown] subscribeNext:^(id x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel soundSetted];
    }];
    //挂断
    [[self.btnEndSession rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        [strongSelf.viewModel sessionComplete];
    }];
    
    // 系统时间显示
    [RACObserve(self, viewModel.systemTime) subscribeNext:^(NSString *x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lbTime.text=x;
        });
    }];
    //监听 对方昵称
    [RACObserve(self, viewModel.peerName) subscribeNext:^(NSString *x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        strongSelf.lbPeerName.text=x;
    }];
    //监听 对方号码
    [RACObserve(self, viewModel.peerNum) subscribeNext:^(NSString *x) {
        __strong AudioSessionViewController *strongSelf=weakSelf;
        strongSelf.lbPeerItel.text=x;
    }];

}
-(void)animation:(UITapGestureRecognizer*)gesture{
    bool show=[self.showControlView boolValue];
    self.showControlView=@(!show);
}
-(void)setHeaderImage{
    [self.headImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.headImageView.layer setBorderWidth:3];
    [self.headImageView.layer setCornerRadius:12];
    [self.headImageView setClipsToBounds:YES];
    
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}

@end
