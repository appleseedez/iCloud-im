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
   //监听 对方名字
    [RACObserve(self, viewModel.peerName) subscribeNext:^(NSString *x) {
        self.lbPeerName.text=x;
    }];
    //监听 对方号码
    [RACObserve(self, viewModel.peerNum) subscribeNext:^(NSString *x) {
        self.lbPeerNumber.text=x;
    }];
    //监听 连接状态
    [RACObserve(self, viewModel.connectionState) subscribeNext:^(NSString *x) {
        self.lbSessionState.text=x;
    }];
    
    //挂断按钮
     [[self.btnHungUp rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
         [self.viewModel sessionComplete];
     }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.viewModel.localSessionView.frame=self.localSessionView.bounds;
    [self.localSessionView addSubview:self.viewModel.localSessionView];
}

@end
