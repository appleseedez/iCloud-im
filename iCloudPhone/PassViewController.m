//
//  PassViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassViewController.h"
#import "RegNextButton.h"
#import "AFNetworking.h"
#import "NetRequester.h"
#import "regDetailTextField.h"
#import "PassWayViewController.h"
#import "NXInputChecker.h"
#import "PassManager.h"
#import "UIImageView+AFNetworking.h"
@interface PassViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtItel;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtVerifyCode;
@property (weak,nonatomic) UIAlertView *failAlert;

@end
#define  SUCCESS void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
#define  FAILURE void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error)
@implementation PassViewController
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.text=nil;
    if (textField==self.txtItel) {
        [self getImage];
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (string.length>0){
    if (textField==self.txtItel) {
        if (textField.text.length>=11) {
            return NO;
        }
      
    }
    else {
        if (textField.text.length>=4) {
            return NO;
        }
           }
    }
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)startHud{
    self.nextButton.enabled=NO;
}
-(void)stopHud{
    self.nextButton.enabled=YES;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
    [self.nextButton setUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"登陆" style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
    [self getToken];
	// Do any additional setup after loading the view.
}
-(IBAction)pushNext:(id)sender{
    if (![NXInputChecker checkEmpty:self.txtItel.text]) {
        [self errorAlert:@"iTel号码不能为空"];
        return;
    }
    if (![NXInputChecker checkEmpty:self.txtVerifyCode.text]) {
        [self errorAlert:@"验证码不能为空"];
        
        return;
    }
    if ([NXInputChecker checkCloudNumber:self.txtItel.text]) {
        [self checkCode];
        [self startHud];
        return;
    }
    
    else {
        [self errorAlert:@"iTel号码格式不正确"];
    }
    
}
-(IBAction)getCheckCodeImage{
    [self getImage];
    }
-(void)getToken{
    NSString *strurl=[NSString stringWithFormat:@"%@/initToken.json",SIGNAL_SERVER];
    
    
    NSURL *url  =[NSURL URLWithString:strurl];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:3];
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",connectionError);
            
            UIAlertView *alert =[[UIAlertView alloc]initWithTitle:@"连接服务器失败" message:@"点击“确定“重新连接,“返回“则退出" delegate:self cancelButtonTitle:@"返回" otherButtonTitles:@"确定", nil];
            self.failAlert=alert;
            dispatch_async(dispatch_get_main_queue(), ^{
                 [alert show];
            });
           

        }
        else{
            NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([[dic objectForKey:@"ret"] intValue]==0) {
               [PassManager defaultManager].token=[[dic objectForKey:@"data" ] objectForKey:@"token"];
                
                [self getImage];
            }
            else{
                
            }
            
            
        }
        
    }];
    

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==self.failAlert) {
        if (buttonIndex==0) {
             [self dismissViewControllerAnimated:YES completion:^{
                 
             }];
        }else if (buttonIndex==1){
            [self getToken];
        }
    }
}
-(void)getImage{
    NSString *strurl=[NSString stringWithFormat:@"%@/printImage",SIGNAL_SERVER];
  
    NSString *parameterUrl=[NSString stringWithFormat:@"%@?token=%@",strurl,[PassManager defaultManager].token];
    NSURL *url  =[NSURL URLWithString:parameterUrl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",connectionError);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
            });
            [self getToken];
            
        }
        else{
            UIImage *image=[UIImage imageWithData:data];
            if ([image isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.codeImage.image=image;
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
                });
            }
        }
        
    }];
    

}
-(void)checkCode{
    NSString *url=[NSString stringWithFormat:@"%@/safety/checkImgCodeItel.json",SIGNAL_SERVER];
    //NSString *url=@"http://211.149.144.15:8000/CloudCommunity/safety/checkImgCodeItel.json";
    NSDictionary *parameters=@{@"itel": self.txtItel.text,@"verifycode":self.txtVerifyCode.text,@"token":[PassManager defaultManager].token};
    SUCCESS{
        [self stopHud];
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic=(NSDictionary*)json;
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [self setManager:[dic objectForKey:@"data"]];
                [self pushNext];
                }
            else {
                //NSLog(@"message:%@   code:%@",[dic objectForKey:@"msg"],[dic objectForKey:@"code"]);
                [self errorAlert:[dic objectForKey:@"msg"]];
            }
        }
    };
    FAILURE{
        [self errorAlert:@"网络不通 请稍后重试"];
        [self stopHud];
        };
    [NetRequester jsonPostRequestWithUrl:url andParameters:parameters success:success failure:failure];

}
-(void)setManager:(NSDictionary*)data{
    PassManager *manager=[PassManager defaultManager];
    manager.questions=data;
    manager.telephone=[data objectForKey:@"phone"];
    manager.itel=[data objectForKey:@"itel"];
    manager.securetyID=[data objectForKey:@"id"];
    manager.userId=[data objectForKey:@"userId"];
    
}
-(void)pushNext{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
    PassWayViewController *passVC=[story instantiateViewControllerWithIdentifier:@"passWayView"];
    
    [PassManager defaultManager].itel=self.txtItel.text;
    [self.navigationController pushViewController:passVC animated:YES];
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:errorString message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
-(void)pop{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
