//
//  HostEditQQViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-20.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditQQViewController.h"
#import "ItelAction.h"
@interface HostEditQQViewController ()
@property (weak, nonatomic) IBOutlet UITextField *QQText;

@end

@implementation HostEditQQViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.QQText.delegate=self;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishButtonClicked)];
}
-(void)finishButtonClicked{
    [[ItelAction action] modifyPersonal:@"qq_num" forValue:self.QQText.text];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.QQText becomeFirstResponder];
    self.QQText.text=[[ItelAction action]getHost].qq ;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location>=13) {
        return NO;
    }
    else return YES;
}

@end
