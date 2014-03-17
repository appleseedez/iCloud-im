//
//  PassResetViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassResetViewController.h"
#import "RegNextButton.h"
#import "PassManager.h"
#import "NXInputChecker.h"
@interface PassResetViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;

@end

@implementation PassResetViewController


-(void)startHud{
    self.nextButton.enabled=NO;
}
-(void)stopHud{
    self.nextButton.enabled=YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.nextButton setUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

        if (range.location>=18) {
            return NO;
        }
        else return YES;
    
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)modifyPassword:(RegNextButton *)sender {
    if ([self.txtPassword.text isEqualToString:self.txtRePassword.text]&&[NXInputChecker checkPassword:self.txtPassword.text]) {
        NSString *password=self.txtPassword.text;
#if USING_PASSWORD_ENCODE
        
        password=[NXInputChecker encodePassWord:password];
#endif

            [self startHud];
            [[PassManager defaultManager] modifyPassword:password];
        
    }else if(![NXInputChecker checkEmpty:self.txtPassword.text]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"密码不能为空" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];

    }
    else if(![NXInputChecker checkEmpty:self.txtRePassword.text]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"确认密码不能为空" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
        
    }
    else if(![NXInputChecker checkPassword:self.txtPassword.text]){
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"密码格式不正确,请输入长度为6-20位的密码" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];

    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码失败" message:@"两次输入密码不一致" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
        
    }
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    [self stopHud];
    if (isNormal) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜修改密码成功" message:@"请牢记您的密码" delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSString *msg=(NSString*)[notification.object objectForKey:@"msg"];
        if (![msg intValue]) {
             msg =@"请稍后重试";
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码失败" message:msg  delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];

    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
       [self.navigationController dismissViewControllerAnimated:YES completion:^{
           
       }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"passChangePassword" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
