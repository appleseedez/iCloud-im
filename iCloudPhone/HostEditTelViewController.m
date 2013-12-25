//
//  HostEditTelViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostEditTelViewController.h"
#import "RegNextButton.h"
#import "NXInputChecker.h"
#import "HostMesViewController.h"
#import "ItelAction.h"
@interface HostEditTelViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtTel;
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (nonatomic,strong) NSString *TheNewTel;
@end

@implementation HostEditTelViewController
-(void)setUI{
    [self.nextButton setUI];
    
}
- (IBAction)nextButtonClicked:(RegNextButton *)sender {
    self.TheNewTel=self.txtTel.text;
    if ([NXInputChecker checkPhoneNumberIsMobile:self.TheNewTel]) {
        [[ItelAction action] checkPhoneNumber:self.TheNewTel];
    }
    else [self showWrongMessage:@"手机号码格式不对"];
}
-(void)showWrongMessage:(NSString*)message{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"验证错误" message:message delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"modifyPhone" object:nil];
}
-(void)receive:(NSNotification*)notification{
    NSDictionary *userInfo=notification.userInfo;
    BOOL isNormal=[[userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        UIStoryboard *story=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
        HostMesViewController *mesVC=[story instantiateViewControllerWithIdentifier:@"HostMesView"];
        mesVC.newTelNum=self.TheNewTel;
        [self.navigationController pushViewController:mesVC animated:YES];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
}


@end
