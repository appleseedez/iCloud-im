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
    
  __weak  id weakSelf=self;
       //监听 头像
    [RACObserve(self, moreViewModel.imgUrl)subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x length]) {
            [strongSelf.imgHead setImageWithURL:[NSURL URLWithString:x] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        }
    }];
       //监听 签名
    [RACObserve(self, moreViewModel.sign) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbSign.text=x;
    }];
    //监听 昵称
    [RACObserve(self, moreViewModel.nickname) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbNickname.text=x;
    }];
    //监听 性别
    [RACObserve(self, moreViewModel.sex) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            [strongSelf.imgSex setImage:[UIImage imageNamed:@"female"]];
        }else{
            [strongSelf.imgSex setImage:[UIImage imageNamed:@"male"]];
        }
    }];
    //监听 生日
    [RACObserve(self, moreViewModel.birthday) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbBirthday.text=x;
    }];
    //监听 所在地
    [RACObserve(self, moreViewModel.area) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbArea.text=x;
    }];
    //监听 手机
    [RACObserve(self, moreViewModel.phone) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbPhone.text=x;
    }];
    //监听 邮箱
    [RACObserve(self, moreViewModel.email) subscribeNext:^(NSString *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbEmail.text=x;
    }];
    //监听 QQ
    [RACObserve(self, moreViewModel.qq) subscribeNext:^(NSString *x) {
    __strong MaoHostSettingViewController *strongSelf=weakSelf;
        strongSelf.lbQQ.text=x;
    }];
    
}
-(void)getCamera{
    
}
-(void)getPhotoBook{
    
}
-(void)editImage{
    
    UIActionSheet *actionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册选取", @"拍照",nil];
    [actionSheet showInView:self.view];
    __weak  id weakSelf=self;
    [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
        __strong MaoHostSettingViewController *strongSelf=weakSelf;
        if ([x longValue]==0) {
             //相册选取
            [strongSelf getPhotoBook];
        }else if ([x longValue]==1){
             //拍照
            [strongSelf getCamera];
        }
    }];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        [self editImage];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
    
}
-(void)setUI{
    [self.imgHead setClipsToBounds:YES];
    [self.imgHead.layer setCornerRadius:8.0];
}
- (void)dealloc
{
    NSLog(@"HostSettingVC成功被销毁");
}
@end
