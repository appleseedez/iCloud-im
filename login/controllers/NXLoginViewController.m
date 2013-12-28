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
#define mockServer [AFHTTPSessionManager manager]

@interface NXLoginViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;

@end

@implementation NXLoginViewController
#pragma  mark - 点击空白退出键盘
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    
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
        
        [self requestToLogin];
    }
}
-(void)requestToLogin{
    //这是退出键盘的 不用理它
    [self.view endEditing:YES];
    self.txtInuptCheckMessage.text=@"登录中...";
    [self.actWaitingToLogin startAnimating];
//    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://211.149.144.15:8000/CloudCommunity/login.json"]];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://10.0.0.40:8080/CloudCommunity/login.json"]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData *httpBody=[NSJSONSerialization dataWithJSONObject:@{@"itel": self.txtUserCloudNumber.text,@"password":self.txtUserPassword.text} options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:httpBody];
  
    
    //success封装了一段代码表示如果请求成功 执行这段代码
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject){
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
       
        if ([json isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic=[json objectForKey:@"message"];
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                HostItelUser *host=[HostItelUser userWithDictionary:[dic objectForKey:@"data"]];
                [[ItelAction action] setHostItelUser:host];
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text = @"";

                NSCAppDelegate *delegate =   (NSCAppDelegate*) [UIApplication sharedApplication].delegate;
                [delegate changeRootViewController:RootViewControllerMain userInfo:[[json valueForKey:@"message"] valueForKey:@"data"]];
                
                [[ItelAction action] checkAddressBookMatchingItel];
                
                //[[ItelAction action] delFriendFromBlack:@"1000002"];
                //[[ItelAction action] getItelBlackList:0];
            }
            else {
                [self.actWaitingToLogin stopAnimating];
                self.txtInuptCheckMessage.text=[dic objectForKey:@"msg"];
            }
        }//如果请求失败 则执行failure
    };
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [self.actWaitingToLogin stopAnimating];
        self.txtInuptCheckMessage.text = @"网络不通";
    };
    AFHTTPRequestOperation *operation=[[AFHTTPRequestOperation alloc]initWithRequest:request];
    [operation setCompletionBlockWithSuccess:success failure:failure];
    //[self sendRequesturl:login parameters:postData success:success failure:failure];
    [operation start];

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
    self.txtUserCloudNumber.text=@"2301031983";
    self.txtUserPassword.text=@"123456";
  
    NXImageView *logo=[[NXImageView alloc]initWithFrame:CGRectMake(0, 0, 75, 75)];
    [logo setRect:3 cornerRadius:10 borderColor:[UIColor whiteColor]];
    [logo setClipsToBounds:YES];
    logo.image=[UIImage imageNamed:@"login_logo"];
    [self.logoImageView addSubview:logo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoLogin:) name:@"regSuccess" object:nil];
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
-(void)autoLogin:(NSNotification*)notification{
    self.txtUserCloudNumber.text=[notification.userInfo objectForKey:@"itel"];
    self.txtUserPassword.text=[notification.userInfo objectForKey:@"password"];
    [self requestToLogin];
}
@end
