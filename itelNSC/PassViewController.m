//
//  PassViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassViewController.h"
#import "PassViewModel.h"
#import "PassWayViewController.h"
#import "PassMesViewController.h"
@interface PassViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet UITextField *txtItel;
@property (weak, nonatomic) IBOutlet UITextField *txtVerifyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnGetImage;
@property (weak,nonatomic) UIAlertView *failAlert;
@property (nonatomic,strong) RACSubject *getImage;
@end

@implementation PassViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonUI];
    self.passViewModel=[[PassViewModel alloc]init];
    self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
    self.getImage=[RACSubject subject];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
      //监听 token
       [RACObserve( self, passViewModel.imgToken) subscribeNext:^(NSString *x) {
           if (x) {
               [self.getImage sendNext:@""];
           }else{
               [self.passViewModel getToken];
           }
       }];
    
    [self.getImage subscribeNext:^(id x) {
        [self.passViewModel getCodedImage];
    }];
    
    //监听 image
    [RACObserve(self, passViewModel.codeImage) subscribeNext:^(UIImage *x) {
        if (x) {
            self.codeImage.image=x;
        }else{
            self.codeImage.image=[UIImage imageNamed:@"code_placeholder"];
        }
        
    }];
    //监听hud
    [RACObserve(self, passViewModel.busy) subscribeNext:^(NSNumber *x) {
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        }
    }];
     //事件 点击换图片
    [[self.btnGetImage rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        [self.passViewModel getToken];
    }];
    //事件 检查密保
    [[self.nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSString *msg=nil;
        if (self.txtItel.text.length==0) {
              msg=@"iTel号码不能为空";
        }else if(self.txtVerifyCode.text.length==0){
               msg=@"验证码不能为空";
        }
        if (msg) {
            [[[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return ;
        }
        self.passViewModel.itel=self.txtItel.text;
        self.passViewModel.code=self.txtVerifyCode.text;
        [self.passViewModel checkSecurity];
    }];
     //监听 密保信息
    [RACObserve(self, passViewModel.securityData) subscribeNext:^(NSDictionary *x) {
        if (x) {
            if ([self.navigationController.childViewControllers lastObject]==self) {
                PassWayViewController *vc=[self.storyboard instantiateViewControllerWithIdentifier:@"passWayView"];
                vc.passViewModel=self.passViewModel;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
    
}
-(void)setButtonUI{
    [self.nextButton setClipsToBounds:YES];
    [self.nextButton.layer setCornerRadius:5.0];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.text=nil;
    if (textField==self.txtItel) {
        [self.getImage sendNext:@""];
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

-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
