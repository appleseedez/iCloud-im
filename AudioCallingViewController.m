//
//  AudioCallingViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AudioCallingViewController.h"
#import "DialViewModel.h"
@interface AudioCallingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lbPeerName;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbSessionState;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerArea;
@property (weak, nonatomic) IBOutlet UIButton *btnHungUp;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@end

@implementation AudioCallingViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        
    }else{
        self.view.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
    [self setHeaderImage];
    __weak id weakSelf=self;
    //监听名字
    [RACObserve(self, viewModel.peerName) subscribeNext:^(NSString *x) {
         __strong AudioCallingViewController *strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lbPeerName.text=x;
        });
    }];
    //监听号码
    [RACObserve(self, viewModel.peerNum) subscribeNext:^(NSString *x) {
         __strong AudioCallingViewController *strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lbPeerNumber.text=x;
        });
    }];
    //监听地址
    [RACObserve(self, viewModel.peerArea) subscribeNext:^(NSString *x) {
         __strong AudioCallingViewController *strongSelf=weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            strongSelf.lbPeerArea.text=x;
        });
    }];
    //挂断按钮
    [[self.btnHungUp rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
         __strong AudioCallingViewController *strongSelf=weakSelf;
        [strongSelf.viewModel sessionComplete];
    }];
    //监听 连接状态
    [RACObserve(self, viewModel.connectionState) subscribeNext:^(NSString *x) {
         __strong AudioCallingViewController *strongSelf=weakSelf;
        strongSelf.lbSessionState.text=x;
    }];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.view.userInteractionEnabled=NO;
    [self.view performSelector:@selector(setUserInteractionEnabled:) withObject:@(YES) afterDelay:0.5];
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
