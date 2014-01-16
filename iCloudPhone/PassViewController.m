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
    if (textField==self.txtItel) {
        if (range.location>=12) {
            return NO;
        }
        else return YES;
    }
    else {
        if (range.location>=4) {
            return NO;
        }
        else return YES;
    }
   
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
    [self getImage];
	// Do any additional setup after loading the view.
}
-(IBAction)pushNext:(id)sender{
    if ([NXInputChecker checkCloudNumber:self.txtItel.text]) {
        [self checkCode];
        [self startHud];
    }
    
    else {
        [self errorAlert:@"iTel格式不对"];
    }
    
}
-(IBAction)getCheckCodeImage{
    [self getImage];
    }
-(void)getImage{
    NSString *strurl=[NSString stringWithFormat:@"%@/printImage",SIGNAL_SERVER];
  
    
    NSURL *url  =[NSURL URLWithString:strurl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",connectionError);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
            });
            
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
    NSDictionary *parameters=@{@"itel": self.txtItel.text,@"verifycode":self.txtVerifyCode.text};
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
               
                [self errorAlert:@"iTel号码不存在或验证码错误"];
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
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"验证错误" message:errorString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
-(void)pop{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
