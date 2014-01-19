//
//  HostEditEmailViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditEmailViewController.h"
#import "ItelAction.h"
#import "NXInputChecker.h"
@interface HostEditEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailText;

@end

@implementation HostEditEmailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.emailText.delegate=self;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}


-(void)finishButtonClicked{
    if ([NXInputChecker checkEmail:self.emailText.text]) {
        [[ItelAction action] modifyPersonal:@"mail" forValue:self.emailText.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"邮箱格式不正确" message:@"请检查您输入的邮箱格式" delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.emailText becomeFirstResponder];
    self.emailText.text=[[ItelAction action]getHost].email ;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location>=20) {
        return NO;
    }
    else return YES;
}
@end
