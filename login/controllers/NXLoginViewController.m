//
//  NXLoginViewController.m
//  social
//
//  Created by nsc on 13-11-5.
//  Copyright (c) 2013年 itelland. All rights reserved.
//@"http://211.149.144.15:9000/CloudCommunity/login.json"

#import "NXLoginViewController.h"
#import "NXInputChecker.h"
#import "NXRegViewController.h"


#import "AFNetworking.h"
#import "NSCAppDelegate.h"
#import "RegNextButton.h"
#import "NXImageView.h"
#import "ItelAction.h"
#import "NetRequester.h"
#define mockServer [AFHTTPSessionManager manager]

@interface NXLoginViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end
static int loginCount=0;
@implementation NXLoginViewController
#pragma  mark - 点击空白退出键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==self.txtUserCloudNumber) {
        self.txtUserCloudNumber.text=nil;
        self.txtUserPassword.text=nil;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==self.txtUserCloudNumber) {
        if (range.location>=11) {
            return NO;
        }
        else return YES;
    }
    else if (textField==self.txtUserPassword){
        if (range.location>=20) {
            return NO;
        }
        else return YES;
    }
    return YES;
}
- (IBAction)presentRegViewController:(UIButton *)sender {
    
    NXRegViewController *reg=[[NXRegViewController alloc]init];
    UINavigationController *regVC= [[UINavigationController alloc]initWithRootViewController:reg];
    [self presentViewController:regVC animated:YES completion:^{
        
    }];

}



#pragma mark - 点击登录按钮
- (IBAction)loginButtonPushed:(UIButton *)sender {
    if (![self checkUserInput]) {
         self.txtInuptCheckMessage.text=@"输入不正确";
    }
    else{
        self.btnLogin.enabled=NO;
        [self requestToLogin];
    }
}
-(void)requestToLogin{
    //这是退出键盘的 不用理它
    [self.view endEditing:YES];
    self.txtInuptCheckMessage.text=@"登录中...";
    [self.actWaitingToLogin startAnimating];
    NSString *url=[NSString stringWithFormat:@"%@/login.json",SIGNAL_SERVER];
    
    loginCount ++;
    NSLog(@"登录了%d次",loginCount);
    
    
    NSDictionary *parameters=  @{@"itel": self.txtUserCloudNumber.text,@"password":self.txtUserPassword.text,@"type":@"IOS"};
    
    
    
    
    //success封装了一段代码表示如果请求成功 执行这段代码
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject){
        
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic=[json objectForKey:@"message"];
            if ([dic objectForKey:@"ret"] == nil) {
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text=[dic objectForKey:@"msg"];
                self.btnLogin.enabled=YES;
                NSLog(@"登录失败:%@",[dic objectForKey:@"msg"]);
                return ;
            }
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                HostItelUser *host=[HostItelUser userWithDictionary:[[dic objectForKey:@"data"] mutableCopy]];
                NSDictionary *tokens=[json objectForKey:@"tokens"];
                if (tokens) {
                    host.sessionId=[tokens objectForKey:@"jsessionid"];
                    host.spring_security_remember_me_cookie=[tokens objectForKey:@"spring_security_remember_me_cookie"];
                    host.token=[tokens objectForKey:@"token"];
                }
                
                
                [[ItelAction action] setHostItelUser:host];
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text = @"";
                
                [[ItelAction action] resetContact];
                
                
                NSCAppDelegate *delegate =   (NSCAppDelegate*) [UIApplication sharedApplication].delegate;
                [delegate changeRootViewController:RootViewControllerMain userInfo:[[json valueForKey:@"message"] valueForKey:@"data"]];
                
                [[ItelAction action] checkAddressBookMatchingItel];
                [[ItelAction action] getItelBlackList:0];
                [[ItelAction action] getItelFriendList:0];
                self.btnLogin.enabled=YES;
            }
            else {
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text=[dic objectForKey:@"msg"];
                self.btnLogin.enabled=YES;
            }
        }//如果请求失败 则执行failure
    };
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self.actWaitingToLogin stopAnimating];
        self.txtInuptCheckMessage.text = @"网络不通";
        self.btnLogin.enabled = YES;
    };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];
}
-(void)requestToLogin1{
    //这是退出键盘的 不用理它
    [self.view endEditing:YES];
    self.txtInuptCheckMessage.text=@"登录中...";
    [self.actWaitingToLogin startAnimating];
    NSString *url=[NSString stringWithFormat:@"%@/login",SIGNAL_SERVER];
    
    loginCount ++;
    NSLog(@"登录了%d次",loginCount);
    
    
    NSDictionary *parameters=  @{@"itel": self.txtUserCloudNumber.text,@"password":self.txtUserPassword.text,@"type":@"IOS",@"_spring_security_remember_me":@"true"};
  
   
    
    
    //success封装了一段代码表示如果请求成功 执行这段代码
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject){
        
        id json=responseObject;
        
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic=[json objectForKey:@"message"];
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                HostItelUser *host=[HostItelUser userWithDictionary:[[dic objectForKey:@"data"] mutableCopy]];
                NSDictionary *tokens=[json objectForKey:@"tokens"];
                if (tokens) {
                    host.sessionId=[tokens objectForKey:@"jsessionid"];
                    host.spring_security_remember_me_cookie=[tokens objectForKey:@"spring_security_remember_me_cookie"];
                    host.token=[tokens objectForKey:@"token"];
                }
                
                
                [[ItelAction action] setHostItelUser:host];
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text = @"";
                
                [[ItelAction action] resetContact];
                
                
                NSCAppDelegate *delegate =   (NSCAppDelegate*) [UIApplication sharedApplication].delegate;
                [delegate changeRootViewController:RootViewControllerMain userInfo:[[json valueForKey:@"message"] valueForKey:@"data"]];
                
                [[ItelAction action] checkAddressBookMatchingItel];
                [[ItelAction action] getItelBlackList:0];
                [[ItelAction action] getItelFriendList:0];
                self.btnLogin.enabled=YES;
            }
            else {
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text=[dic objectForKey:@"msg"];
                self.btnLogin.enabled=YES;
            }
        }//如果请求失败 则执行failure
    };
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self.actWaitingToLogin stopAnimating];
        self.txtInuptCheckMessage.text = @"网络不通";
        self.btnLogin.enabled = YES;
    };
    [[AFHTTPRequestOperationManager manager]POST:url parameters:parameters success:success failure:failure];
}
#pragma mark - 检测用户输入

-(BOOL)checkUserInput{
    
    return [NXInputChecker checkCloudNumber:self.txtUserCloudNumber.text]&&[NXInputChecker checkPassword:self.txtUserPassword.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    self.actWaitingToLogin.hidesWhenStopped=YES;
    //self.txtUserCloudNumber.text=@"500009";

    //self.txtUserPassword.text=@"111111";
  
    NXImageView *logo=[[NXImageView alloc]initWithFrame:CGRectMake(0, 0, 75, 75)];
    [logo setRect:3 cornerRadius:10 borderColor:[UIColor whiteColor]];
    [logo setClipsToBounds:YES];
    logo.image=[UIImage imageNamed:@"login_logo"];
    [self.logoImageView addSubview:logo];
    
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
    [self.btnLogin setUI];
    
}
-(void)conformKeyBoard:(NSNotification*)notification{
    CGFloat keyBoardHeightDelta;

    NSDictionary *info= notification.userInfo;
 
    CGRect beginRect=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    keyBoardHeightDelta=beginRect.origin.y-endRect.origin.y;

    [UIView animateKeyframesWithDuration:0.30 delay:0.2 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        
        self.view.center=CGPointMake(self.view.center.x, self.view.center.y-keyBoardHeightDelta/2);
            } completion:^(BOOL finished) {
        
    }];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
