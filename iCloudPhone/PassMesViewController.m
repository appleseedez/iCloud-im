//
//  PassMesViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassMesViewController.h"
#import "PassManager.h"
#import "PassResetViewController.h"
#import "PersonRegButton.h"
#import "RegNextButton.h"
#import "RegTipLabel.h"
#import "NXInputChecker.h"
@interface PassMesViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtCheckCode;
@property (weak, nonatomic) IBOutlet PersonRegButton *btnReSend;
@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet RegTipLabel *tipView;

@end

@implementation PassMesViewController
static int waitingTime=60;

-(void)startHud{
    self.nextButton.enabled=NO;
}
-(void)stopHud{
    self.nextButton.enabled=YES;
}
-(void)setUI{
    [self.nextButton setUI];
    [self.tipView setUI];
    [self.btnReSend setUI];
    self.btnReSend.high=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    self.btnReSend.normal=[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    self.btnReSend.backgroundColor=self.btnReSend.normal;
    NSString *tel=[self getTelephone];
    NSString *codedTel=[NXInputChecker encodeTelNumber:tel];
    if (codedTel!=nil) {
        self.tipLabel.text=[NSString stringWithFormat:@"请输入手机%@收到的短信校验码",codedTel];
    }
    [self.btnReSend.layer setCornerRadius:5.0];
}

-(void)TimerStart{
    waitingTime=60;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerBeat) userInfo:nil repeats:YES];
    self.btnReSend.backgroundColor=[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];
    self.btnReSend.enabled=NO;
   
    
}
-(void)timerEnd{
    [self.timer invalidate] ;
   
}
-(void)timerBeat{
    if (waitingTime) {
        waitingTime--;
        [self refreshButton];
    }
    else {
        [self.timer invalidate];
        [self refreshButton];
        
    }
}
-(void)refreshButton{
    NSString  *title=nil;
    if (waitingTime) {
        title=[NSString stringWithFormat:@"(%d秒后)重新发送",waitingTime];
    }
    else{
        title=@"点击重新发送";
        self.btnReSend.enabled=YES;
        self.btnReSend.backgroundColor=[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
        [self timerEnd];
    }
    [self.btnReSend setTitle:title forState:UIControlStateNormal];
    [self.btnReSend setTitle:title forState:UIControlStateDisabled];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
     self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    [[PassManager defaultManager] sendMessage];
    [self setUI];
    [self TimerStart];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(NSString*)getTelephone{
    return [PassManager defaultManager].telephone;
}

- (IBAction)checkCode:(UIButton *)sender{
    [self startHud];
    [[PassManager defaultManager] checkMessageCode:self.txtCheckCode.text];
}
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCodeResponse:) name:@"passPhoneCheckCode" object:nil];
}
-(void)pop{
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)checkCodeResponse:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    [self stopHud];
    if (isNormal) {
        UIStoryboard *story=[UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
        PassResetViewController *passResetVC=[story instantiateViewControllerWithIdentifier:@"passReset"];
        [self.navigationController pushViewController:passResetVC animated:YES];
    }
    else{
        NSString *msg=[notification.userInfo objectForKey:@"reason"];
        if (![msg intValue]) {
            msg =@"请稍后重试";
        }
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"短信验证失败" message:msg  delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addNotification];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [self timerEnd];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)messageButton:(UIButton *)sender {
    [self TimerStart];
    [self resendMessage];
    
}

-(void)resendMessage{
    [[PassManager defaultManager]sendMessage];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}
@end
