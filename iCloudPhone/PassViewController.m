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
@interface PassViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtItel;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtVerifyCode;

@end
#define  SUCCESS void (^success)(AFHTTPRequestOperation *operation, id responseObject) = ^(AFHTTPRequestOperation *operation, id responseObject)
#define  FAILURE void (^failure)(AFHTTPRequestOperation *operation, NSError *error)   = ^(AFHTTPRequestOperation *operation, NSError *error)
@implementation PassViewController


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.nextButton setUI];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"登陆" style:UIBarButtonItemStyleDone target:self action:@selector(pop)];
    [self getImage];
	// Do any additional setup after loading the view.
}
-(IBAction)pushNext:(id)sender{
    if ([NXInputChecker checkCloudNumber:self.txtItel.text]) {
        [self checkCode];
    }
    
    else {
        [self errorAlert:@"iTel格式不对"];
    }
    
}
-(IBAction)getCheckCodeImage{
    [self getImage];
    }
-(void)getImage{
    NSString *strurl=@"http://10.0.0.150:8080/CloudCommunity/printImage";
    
    NSURL *url  =[NSURL URLWithString:strurl];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    NSOperationQueue *queue=[[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            NSLog(@"%@",connectionError);
        }
        else{
            UIImage *image=[UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.codeImage.image=image;
            });
        }
        
    }];

}
-(void)checkCode{
    NSString *url=@"http://10.0.0.150:8080/CloudCommunity/safety/checkImgCodeItel.json";
    NSDictionary *parameters=@{@"itel": self.txtItel.text,@"verifycode":self.txtVerifyCode.text};
    SUCCESS{
        id json=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if ([json isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic=(NSDictionary*)json;
            int ret=[[dic objectForKey:@"ret"] intValue];
            if (ret==0) {
                [self setManager:[dic objectForKey:@"data"]];
                [self pushNext];
                }
            else {
               
                [self errorAlert:@"验证输入码错误"];
            }
        }
    };
    FAILURE{
        [self errorAlert:@"网络不通 请稍后重试"];
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
