//
//  HostMesViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-23.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostMesViewController.h"
#import "ItelAction.h"
@interface HostMesViewController ()
@property (nonatomic,weak) IBOutlet UITextField *txtCheckCode;
@end

@implementation HostMesViewController
-(NSString*)newTelNum{
    return _newTelNum;
}
-(void)setNewTelNum:(NSString*)newTelNum{
    _newTelNum=newTelNum;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
	// Do any additional setup after loading the view.
}

-(NSString*)getTelephone{
    return self.newTelNum;
}

- (IBAction)checkCode:(UIButton *)sender{
    [[ItelAction action] phoneCheckCode:self.txtCheckCode.text phone:self.newTelNum];
}
-(void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCodeResponse:) name:@"phoneCheckCode" object:nil];
}
-(void)checkCodeResponse:(NSNotification*)notification{
    NSString *message=nil;
    NSDictionary *userInfo=notification.userInfo;
    BOOL isNormal=[[userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        message = [NSString stringWithFormat:@"您的绑定手机现在已经改为%@",self.newTelNum];
      HostItelUser *host=  [[ItelAction action] getHost];
        host.telNum=self.newTelNum;
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"修改成功" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    else{
        message=[notification.userInfo objectForKey:@"reason"];
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"验证失败" message:message delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)resendMessage{
    [[ItelAction action] resendMassage:self.newTelNum];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismiss];
}
@end
