//
//  VideoCallingViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "VideoCallingViewController.h"
#import "DialViewModel.h"
@interface VideoCallingViewController ()
@property (weak, nonatomic) IBOutlet UIView *localSessionView;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerName;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbSessionState;
@property (weak, nonatomic) IBOutlet UIButton *btnHungUp;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerArea;
@end

@implementation VideoCallingViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        
    }else{
        self.view.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
    __weak id weakSelf=self;
   //监听 对方名字
    [RACObserve(self, viewModel.peerName) subscribeNext:^(NSString *x) {
        __strong VideoCallingViewController *strongSelf=weakSelf;
        strongSelf.lbPeerName.text=x;
    }];
    //监听 对方号码
    [RACObserve(self, viewModel.peerNum) subscribeNext:^(NSString *x) {
        __strong VideoCallingViewController *strongSelf=weakSelf;
        strongSelf.lbPeerNumber.text=x;
    }];
    //监听 连接状态
    [RACObserve(self, viewModel.connectionState) subscribeNext:^(NSString *x) {
        __strong VideoCallingViewController *strongSelf=weakSelf;
        strongSelf.lbSessionState.text=x;
    }];
    
    //挂断按钮
     [[self.btnHungUp rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
         __strong VideoCallingViewController *strongSelf=weakSelf;
         [strongSelf.viewModel sessionComplete];
     }];
    [[RACObserve(self, viewModel.localSessionView) map:^id(id value) {
        
        
        
        return value;
    }]subscribeNext:^(id x) {}];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.viewModel.localSessionView.frame=self.localSessionView.bounds;
    [self.localSessionView addSubview:self.viewModel.localSessionView];
    ((CALayer*)self.viewModel.localSessionView.layer.sublayers[0]).frame=self.viewModel.localSessionView.bounds;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.viewModel.localSessionView removeFromSuperview];
}
-(void)dealloc{
    NSLog(@"%@被销毁",self);
}
@end
