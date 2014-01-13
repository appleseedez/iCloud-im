//
//  RegMesCheckViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-10.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "RegMesCheckViewController.h"
#import "RegManager.h"
#import "NSCAlertView.h"
#import "RegNextButton.h"
#import "RegTipLabel.h"
#import "NXInputChecker.h"
#import "PersonRegButton.h"
@interface RegMesCheckViewController ()
@property (weak, nonatomic) IBOutlet PersonRegButton *btnReSend;
@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet RegTipLabel *tipView;
@property (weak, nonatomic) IBOutlet UITextField *txtCheckCode;

@end

@implementation RegMesCheckViewController
static int waitingTime=6;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)startHud{
    self.nextButton.enabled=NO;
}
-(void)stopHud{
    self.nextButton.enabled=YES;
}
-(void)setUI{
    [self.nextButton setUI];
    [self.tipView setUI];
    NSString *tel=[self getTelephone];
    NSString *codedTel=[NXInputChecker encodeTelNumber:tel];
    if (codedTel!=nil) {
        self.tipLabel.text=[NSString stringWithFormat:@"请输入手机%@收到的短信校验码",codedTel];
    }
    [self.btnReSend.layer setCornerRadius:5.0];
}
-(NSString*)getTelephone{
    return  [RegManager defaultManager].regPhoneNumber;
}
-(void)TimerStart{
    waitingTime=60;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerBeat) userInfo:nil repeats:YES];
    self.btnReSend.enabled=NO;
    self.btnReSend.backgroundColor=[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1];

}
-(void)timerEnd{
    [self.timer invalidate] ;
    self.timer = nil;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    [self setUI];
    [self TimerStart];
   
	// Do any additional setup after loading the view.
}
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)checkCode:(UIButton *)sender {
   
  
    

    [self startHud];
    [[RegManager defaultManager] commitInterfaceCheckCode:self.txtCheckCode.text];
}
-(void)pop{
    [self.view endEditing:YES];
 
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self addNotification];
    
}
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkCodeResponse:) name:COMMIT_INTERFACE_NOTIFICATION object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self timerEnd];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)checkCodeResponse:(NSNotification*)notification{
    NSDictionary *response=(NSDictionary*)notification.object;
    NSInteger ret=[[response objectForKey:@"ret"] integerValue] ;
    [self stopHud];
    
    if (ret==0 && [[notification.userInfo valueForKey:@"success"] boolValue]) {
         //自动登陆
        NSString *message=[NSString stringWithFormat:@"iTel号码 %@ 已经被您注册，请牢记您的iTel号码，以免丢失",[RegManager defaultManager].regItel];
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜,注册成功" message:message delegate:self cancelButtonTitle:@"返回登陆" otherButtonTitles: nil];
        [alert show];
 
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"验证失败" message:@"验证码错误" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
}
- (IBAction)messageButton:(UIButton *)sender {
    [self TimerStart];
    [self resendMessage];
   
}
-(void)resendMessage{
     [[RegManager defaultManager] sendMessageInterface];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSDictionary *userInfo=@{@"itel":[RegManager defaultManager].regItel,@"password":[RegManager defaultManager].regPassword};
 
    [[NSNotificationCenter defaultCenter] postNotificationName:REG_SUCCESS_NOTIFICATION object:nil userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
