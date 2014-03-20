//
//  HostEditNicknameViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-19.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditNicknameViewController.h"
#import "ItelAction.h"
@interface HostEditNicknameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtNIckName;

@end

@implementation HostEditNicknameViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtNIckName.delegate = self;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}
-(void)finishButtonClicked{
    [[ItelAction action] modifyPersonal:@"nick_name" forValue:self.txtNIckName.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.txtNIckName becomeFirstResponder];
    self.txtNIckName.text=[[ItelAction action]getHost].nickName ;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length>0) {
        
        if (textField.text.length+string.length>8) {
        return NO;
        }
    }
  return YES;
}
@end
