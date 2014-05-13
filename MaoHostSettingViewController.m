//
//  MaoHostSettingViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MaoHostSettingViewController.h"
#import "MoreViewModel.h"
#import <UIImageView+AFNetworking.h>
@interface MaoHostSettingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lbSign;
@property (weak, nonatomic) IBOutlet UILabel *lbNickname;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UITextField *lbBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lbArea;
@property (weak, nonatomic) IBOutlet UILabel *lbPhone;
@property (weak, nonatomic) IBOutlet UILabel *lbEmail;
@property (weak, nonatomic) IBOutlet UILabel *lbQQ;

@end

@implementation MaoHostSettingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUI];
       //监听 头像
    [RACObserve(self, moreViewModel.imgUrl)subscribeNext:^(NSString *x) {
        if ([x length]) {
            [self.imgHead setImageWithURL:[NSURL URLWithString:x] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        }
    }];
       //监听 签名
    [RACObserve(self, moreViewModel.sign) subscribeNext:^(NSString *x) {
        self.lbSign.text=x;
    }];
    //监听 昵称
    [RACObserve(self, moreViewModel.nickname) subscribeNext:^(NSString *x) {
        self.lbNickname.text=x;
    }];
    //监听 性别
    [RACObserve(self, moreViewModel.sex) subscribeNext:^(NSString *x) {
        if ([x boolValue]) {
            [self.imgSex setImage:[UIImage imageNamed:@"female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"male"]];
        }
    }];
    //监听 生日
    [RACObserve(self, moreViewModel.birthday) subscribeNext:^(NSString *x) {
        self.lbBirthday.text=x;
    }];
    //监听 所在地
    [RACObserve(self, moreViewModel.area) subscribeNext:^(NSString *x) {
        self.lbArea.text=x;
    }];
    //监听 手机
    [RACObserve(self, moreViewModel.phone) subscribeNext:^(NSString *x) {
        self.lbPhone.text=x;
    }];
    //监听 邮箱
    [RACObserve(self, moreViewModel.email) subscribeNext:^(NSString *x) {
        self.lbEmail.text=x;
    }];
    //监听 QQ
    [RACObserve(self, moreViewModel.qq) subscribeNext:^(NSString *x) {
        self.lbQQ.text=x;
    }];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
    
}
-(void)setUI{
    [self.imgHead setClipsToBounds:YES];
    [self.imgHead.layer setCornerRadius:8.0];
}
@end
