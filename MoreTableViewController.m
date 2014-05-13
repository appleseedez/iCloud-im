//
//  MoreTableViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreTableViewController.h"
#import "MoreViewModel.h"
#import <UIImageView+AFNetworking.h>
#import "AppService.h"
#import "MaoHostSettingViewController.h"
@interface MoreTableViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lbNickname;
@property (weak, nonatomic) IBOutlet UILabel *lbItel;

@end

@implementation MoreTableViewController

-(void)setButtonUI{
    [self.btnLogout setClipsToBounds:YES];
    [self.btnLogout.layer setCornerRadius:5.0];
    [self.imgHead setClipsToBounds:YES];
    [self.imgHead.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.imgHead.layer setCornerRadius:8.0];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.moreViewModel=[[MoreViewModel alloc]init];
    [self setButtonUI];
    
    //监听 nickname
    [RACObserve(self, moreViewModel.nickname) subscribeNext:^(NSString *x) {
        self.lbNickname.text=x;
    }];
    //监听 itel
    [RACObserve(self, moreViewModel.itel) subscribeNext:^(NSString *x) {
        self.lbItel.text=x;
    }];
    //监听 头像
    [RACObserve(self, moreViewModel.imgUrl) subscribeNext:^(NSString *x) {
        if (x) {
            [self.imgHead setImageWithURL:[NSURL URLWithString:x] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        }
    }];
    //事件 退出登录
    [[self.btnLogout rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [[AppService defaultService] logout];
    }];
  
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showTabbar" object:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((MaoHostSettingViewController*)segue.destinationViewController).moreViewModel=self.moreViewModel;
    
}
@end
