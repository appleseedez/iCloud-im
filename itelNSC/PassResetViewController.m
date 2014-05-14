//
//  PassResetViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-7.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassResetViewController.h"
#import "PassViewModel.h"
@interface PassResetViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;

@end

@implementation PassResetViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    __weak id weakSelf=self;
    
    //监听hud
    [RACObserve(self, passViewModel.busy) subscribeNext:^(NSNumber *x) {
        
      __strong  PassResetViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    
    //监听 输入检测
    [RACObserve(self, passViewModel.passwordCheckPassed) subscribeNext:^(NSNumber *x) {
        __strong  PassResetViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            [strongSelf.passViewModel sendNewPassword];
        }
    }];
    
    //事件 开始输入检测
    [[self.btnFinish rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        __strong  PassResetViewController *strongSelf=weakSelf;
        strongSelf.passViewModel.theNewPassword=strongSelf.txtPassword.text;
        strongSelf.passViewModel.theNewRePassword=strongSelf.txtRePassword.text;
        [strongSelf.passViewModel checkPassword];
    }];
     //监听 修改密码成功
    [RACObserve(self, passViewModel.taskSuccess) subscribeNext:^(NSNumber *x) {
        __strong  PassResetViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
           UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"修改密码成功" message:@"请牢记您的密码" delegate:strongSelf cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
                   [strongSelf.navigationController dismissViewControllerAnimated:YES completion:^{
                       
                   }];
            }];
            
        }
    }];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)setButtonUI{
    [self.btnFinish setClipsToBounds:YES];
    [self.btnFinish.layer setCornerRadius:5.0];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)dealloc
{
    NSLog(@"PassResetVC被销毁");
}
@end
