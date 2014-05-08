//
//  VideoAnsweringViewController.m
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "VideoAnsweringViewController.h"
#import "DialViewModel.h"
@interface VideoAnsweringViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImagerView;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerName;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerNumber;
@property (weak, nonatomic) IBOutlet UILabel *lbPeerArea;
@property (weak, nonatomic) IBOutlet UIButton *btnVideoAnswer;
@property (weak, nonatomic) IBOutlet UIButton *btnAudioAnswer;
@property (weak, nonatomic) IBOutlet UIButton *btnHungUp;
@property (weak, nonatomic) IBOutlet UILabel *lbSessionState;

@end

@implementation VideoAnsweringViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0) {
        
    }else{
        self.view.frame=CGRectMake(0, 0, 320, self.view.frame.size.height);
    }
    [self setHeaderImage];
    //监听名字
    [RACObserve(self, viewModel.peerName) subscribeNext:^(NSString *x) {
         dispatch_async(dispatch_get_main_queue(), ^{
             self.lbPeerName.text=x;
         });
    }];
    //监听号码
    [RACObserve(self, viewModel.peerNum) subscribeNext:^(NSString *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lbPeerNumber.text=x;
        });
    }];
    //监听地址
    [RACObserve(self, viewModel.peerArea) subscribeNext:^(NSString *x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lbPeerArea.text=x;
        });
    }];
    //语音接听
     [[self.btnAudioAnswer rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         self.viewModel.localCanVideo=@(NO);
         [self.viewModel answer];
     }];
    //视频接听
    [[self.btnVideoAnswer rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        self.viewModel.localCanVideo=@(YES);
        [self.viewModel answer];
    }];
    //挂断
    [[self.btnHungUp rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       
        [self.viewModel sessionComplete];
    }];
    //监听状态
    [RACObserve(self, viewModel.connectionState) subscribeNext:^(NSString *x) {
        self.lbSessionState.text=x;
    }];
    //监听头像
    [RACObserve(self, viewModel.peerHeader) subscribeNext:^(UIImage *x) {
        self.headImagerView.image=x;
    }];
}
-(void)setHeaderImage{
    [self.headImagerView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.headImagerView.layer setBorderWidth:3];
    [self.headImagerView.layer setCornerRadius:12];
    [self.headImagerView setClipsToBounds:YES];

}

@end
