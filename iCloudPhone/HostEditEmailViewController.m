//
//  HostEditEmailViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditEmailViewController.h"
#import "ItelAction.h"
@interface HostEditEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailText;

@end

@implementation HostEditEmailViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	 self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}


-(void)finishButtonClicked{
    [[ItelAction action] modifyPersonal:@"mail" forValue:self.emailText.text];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
