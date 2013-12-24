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
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}
-(void)finishButtonClicked{
    [[ItelAction action] modifyPersonal:@"nick_name" forValue:self.txtNIckName.text];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
