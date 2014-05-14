//
//  PassEmailViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-7.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassEmailViewController.h"
#import "PassViewModel.h"
#import "PassResetViewController.h"
#import "NXInputChecker.h"
@interface PassEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtCode;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UILabel *lbTip;
@property (weak, nonatomic) IBOutlet UILabel *lbTipTitle;
@end

@implementation PassEmailViewController

-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonUI];
    [self setTipUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    __weak id weakSelf=self;
    //监听hud
    [RACObserve(self, passViewModel.busy) subscribeNext:^(NSNumber *x) {
      __strong  PassEmailViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    
    //监听 邮箱
    [RACObserve(self, passViewModel.securityData) subscribeNext:^(NSDictionary *x) {
         __strong  PassEmailViewController *strongSelf=weakSelf;
        NSString *email=[x objectForKey:@"mail"];
        NSArray *array = [email componentsSeparatedByString:@"@"];
        NSLog(@"%@",array);
        NSString *frant=[array objectAtIndex:0];
        NSString *back=[array objectAtIndex:1];
        if (frant.length>4) {
            NSRange range;
            range.length=frant.length-4;
            range.location=0;
            NSString *head=[frant substringWithRange:range];
            frant=[NSString stringWithFormat:@"%@****",head];
        }else{
            frant=@"****";
        }
        
        strongSelf.lbTipTitle.text=[NSString stringWithFormat:@"请输入邮箱%@@%@收到的校验码",frant,back];
    }];
    //事件 重新发送
    [[self.btnResend rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         __strong  PassEmailViewController *strongSelf=weakSelf;
        [strongSelf.passViewModel sendEmail];
    }];
    //监听 弹出修改密码页面
    [RACObserve(self, passViewModel.showModifyPassView) subscribeNext:^(NSNumber *x) {
         __strong  PassEmailViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            PassResetViewController *vc = [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"PassReset"];
            vc.passViewModel=strongSelf.passViewModel;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }
        
    }];
    
    //事件 下一步
    [[self.btnNext rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
         __strong  PassEmailViewController *strongSelf=weakSelf;
        if (![NXInputChecker checkEmpty:strongSelf.txtCode.text]) {
            [[[UIAlertView alloc]initWithTitle:@"请输入校验码" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
            return ;
        }else{
            [strongSelf.passViewModel emailCodeCheck:strongSelf.txtCode.text];
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
- (void)dealloc
{
    NSLog(@"passEmail被销毁");
}

@end
