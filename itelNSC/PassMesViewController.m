//
//  PassMesViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassMesViewController.h"
#import "PassViewModel.h"
#import "PassResetViewController.h"
@interface PassMesViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UILabel *lbTip;
@property (weak, nonatomic) IBOutlet UILabel *lbTipTitle;
@end

@implementation PassMesViewController



-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   
    self.passViewModel.startTimer=@(NO);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonUI];
    [self setTipUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    //监听 手机号码
    [RACObserve(self, passViewModel.securityData) subscribeNext:^(NSDictionary *x) {
        NSString *phone=[x objectForKey:@"phone"];
        NSRange fore;
        fore.length=3;
        fore.location=0;
        NSString *foreString= [phone substringWithRange:fore];
        NSRange back;
        back.length=4;
        back.location=7;
        NSString *backString=[phone substringWithRange:back];
        self.lbTipTitle.text=[NSString stringWithFormat:@"请输入手机%@****%@收到的短信校验码",foreString,backString];
    }];
    //监听hud
    [RACObserve(self, passViewModel.busy) subscribeNext:^(NSNumber *x) {
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];

    //监听 定时器 是否启动
    [RACObserve(self, passViewModel.startTimer) subscribeNext:^(NSNumber *x) {
        if ([x boolValue]) {
            self.btnResend.enabled=NO;
            
        }else{
            self.btnResend.enabled=YES;
        }
    }];
    //监听 剩余时间
    [RACObserve(self, passViewModel.lastTime) subscribeNext:^(NSString *x) {
        NSString *time;
        
        time=[NSString stringWithFormat:@"在%@秒后点击重新发送",x];
        
        
        [self.btnResend setTitle:@"点击重新发送短信" forState:UIControlStateNormal];
        [self.btnResend setTitle:time forState:UIControlStateDisabled];
    }];
    //事件 重发短信
    [[self.btnResend rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (x) {
            [self.passViewModel sendMessage];
        }
        
    }];
    
    //事件 提交短信吗
    [[self.btnNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        if (self.txtCode.text.length==0) {
            [[[UIAlertView alloc]initWithTitle:@"验证码不能为空" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return ;
        }else{
            [self.passViewModel checkMesCode:self.txtCode.text];
        }
    }];
    //监听 弹出修改密码页面
    [RACObserve(self, passViewModel.showModifyPassView) subscribeNext:^(NSNumber *x) {
        if ([x boolValue]) {
          PassResetViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PassReset"];
            vc.passViewModel=self.passViewModel;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
    
}
-(void)setButtonUI{
    [self.btnResend setClipsToBounds:YES];
    [self.btnNext setClipsToBounds:YES];
    [self.btnNext.layer setCornerRadius:5.0];
    [self.btnResend.layer setCornerRadius:5.0];
}
-(void)setTipUI{
    UIColor *borderColor=[UIColor colorWithRed:0.875 green:0.698 blue:0.447 alpha:1];
    
    
    
    UIColor *backColor=[UIColor colorWithRed:1 green:0.91 blue:0.78 alpha:1];
    [self.lbTip.layer setBorderColor:borderColor.CGColor];
    
    [self.lbTip setBackgroundColor:backColor];
    [self.lbTip.layer setBorderWidth:1];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==self.txtCode) {
        if (range.location>=6) {
            return NO;
        }
        else return YES;
    }
    return YES;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}



@end
