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



- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.nextButton setUI];
}

- (IBAction)modifyPassword:(RegNextButton *)sender {
    if ([self.txtPassword.text isEqualToString:self.txtRePassword.text]) {
        if ([NXInputChecker checkPassword:self.txtPassword.text]) {
            [[PassManager defaultManager] modifyPassword:self.txtPassword.text];
        }
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码成功失败" message:@"密码格式不正确" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];

    }
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    if (isNormal) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜修改密码成功" message:@"请牢记您的密码" delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSString *msg=(NSString*)[notification.object objectForKey:@"msg"];
        if (![msg intValue]) {
             msg =@"请稍后重试";
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"修改密码成功失败" message:msg  delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
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
