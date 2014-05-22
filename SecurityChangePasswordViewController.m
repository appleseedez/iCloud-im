//
//  SecurityChangePasswordViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityChangePasswordViewController.h"

#import "MBProgressHUD.h"
#import "NXInputChecker.h"
#import "MoreChangePasswordViewModel.h"
#define TXT_OLD_PASSWORD_TAG 510001
#define TXT_NEW_PASSWORD_TAG 510002
#define TXT_NEW_RE_PASSWORD_TAG 510003

@interface SecurityChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) UIView *inputAccessoryView;
@end

@implementation SecurityChangePasswordViewController

static long currEditingTextTag=0;

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currEditingTextTag=textField.tag;
}

-(UIView*)inputAccessoryView{
    if (_inputAccessoryView==nil) {
        _inputAccessoryView=[[UIView alloc]init];
        _inputAccessoryView.bounds=CGRectMake(0, 0, 320, 44.5);
        _inputAccessoryView.backgroundColor=[UIColor whiteColor];
        UIButton *foreward=[[UIButton alloc]initWithFrame:CGRectMake(106, 0, 109, 43)];
        [foreward setTitle:@"下一个" forState:UIControlStateNormal];
        [foreward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [foreward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
        [foreward addTarget:self action:@selector(chanegeToNextText) forControlEvents:UIControlEventTouchUpInside];
        [foreward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_inputAccessoryView addSubview:foreward];
        UIButton *backward=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 105, 43)];
        [backward setTitle:@"上一个" forState:UIControlStateNormal];
        backward.backgroundColor=[UIColor whiteColor];
        [backward addTarget:self action:@selector(changeToLast) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:backward];
        [backward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIButton *end=[[UIButton alloc]initWithFrame:CGRectMake(216, 0, 106, 43)];
        [end setTitle:@"结束" forState:UIControlStateNormal];
        [backward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [backward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
        [end addTarget:self action:@selector(returnKeyBoard) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:end];
        [end setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [end setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [end setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
    }
    return _inputAccessoryView;
}
-(void)chanegeToNextText{
    UITextField *text=nil;
    float nextTag=0;
    switch (currEditingTextTag) {
        case TXT_OLD_PASSWORD_TAG:
            nextTag=TXT_NEW_PASSWORD_TAG;
            break;
        case TXT_NEW_PASSWORD_TAG:
            nextTag=TXT_NEW_RE_PASSWORD_TAG;
            break;
        case TXT_NEW_RE_PASSWORD_TAG:
            nextTag=TXT_OLD_PASSWORD_TAG;
            break;
        default:
            break;
    }
    text=(UITextField*)[self.view viewWithTag:nextTag];
    [text becomeFirstResponder];
}
-(void)changeToLast{
    UITextField *last=nil;
    float nextTag=0;
    switch (currEditingTextTag) {
        case TXT_NEW_PASSWORD_TAG:
            nextTag=TXT_OLD_PASSWORD_TAG;
            break;
        case TXT_NEW_RE_PASSWORD_TAG:
            nextTag=TXT_NEW_PASSWORD_TAG;
            break;
        case TXT_OLD_PASSWORD_TAG:
            nextTag=TXT_NEW_RE_PASSWORD_TAG;
            break;
        default:
            break;
    }
    last=(UITextField*)[self.view viewWithTag:nextTag];
    [last becomeFirstResponder];
}
-(void)returnKeyBoard{
    [self.view endEditing:YES];
}
-(void)setTextUI:(UIView*)textView{
    [textView.layer setBorderWidth:1];
    [textView.layer setBorderColor:[UIColor colorWithRed:0.8888 green:0.8888 blue:0.8888 alpha:1].CGColor];
}
-(void)setSubViewUI{
    [self.nextButton setClipsToBounds:YES];
    [self.nextButton.layer setCornerRadius:5.0];
    [self setTextUI:self.txtNewPassword];
    [self setTextUI:self.txtOldPassword];
    [self setTextUI:self.txtRepeatPassword];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtNewPassword.inputAccessoryView=self.inputAccessoryView;
    self.txtOldPassword.inputAccessoryView=self.inputAccessoryView;
    self.txtRepeatPassword.inputAccessoryView=self.inputAccessoryView;
    [self setSubViewUI];
    self.changePasswordViewModel =[[MoreChangePasswordViewModel alloc]init];
    __weak id weakSelf=self;
    //监听hud
    [RACObserve(self, changePasswordViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong SecurityChangePasswordViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    
     [RACObserve(self, changePasswordViewModel.passwordChanged) subscribeNext:^(NSNumber *x) {
         __strong SecurityChangePasswordViewController *strongSelf=weakSelf;
         if ([x boolValue]) {
             [strongSelf.navigationController popViewControllerAnimated:YES];
               }
     }];

}
-(void)conformKeyBoard:(NSNotification *)notification
{
    //NSLog(@"键盘高度即将变化");
    CGFloat keyBoardHeightDelta;
    //获取信件
    NSDictionary *info= notification.userInfo;
    //NSLog(@"通知携带的信息:%@",info);
    CGRect beginRect=[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect endRect=[[info objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    keyBoardHeightDelta=beginRect.origin.y-endRect.origin.y;
    UIScrollView *scroll=self.scrollView;
    UIView *txt=[self.view viewWithTag:currEditingTextTag];
    float currTextY=txt.frame.origin.y;
    [UIView animateWithDuration:0.30 delay:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
       
        if (keyBoardHeightDelta>0) {
            scroll.frame=CGRectMake(0, 0, scroll.bounds.size.width, scroll.bounds.size.height-keyBoardHeightDelta);
            scroll.contentSize=self.view.bounds.size;
            scroll.contentOffset=CGPointMake(scroll.contentOffset.x, currTextY-scroll.bounds.size.height/2);
        }
        else{
            scroll.frame=self.view.bounds ;
            scroll.contentOffset=CGPointMake(0,0);
        }
    } completion:^(BOOL finished) {
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (IBAction)checkUserInput:(UIButton *)sender {
    [self returnKeyBoard];
   
    NSString *localCheck=[self checkInputFormat];
    if (localCheck==nil) {
        
        NSString *newPassword=self.txtNewPassword.text;
        NSString *oldPassword=self.txtOldPassword.text;

        
        newPassword=[NXInputChecker encodePassWord:newPassword];
        oldPassword=[NXInputChecker encodePassWord:oldPassword];
      
        [self.changePasswordViewModel changePassword:newPassword oldPassword:oldPassword];

        
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"验证失败" message:localCheck delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}
-(NSString*)checkInputFormat{
    
    if (![NXInputChecker checkPassword:self.txtOldPassword.text]) {
        return @"密码格式不正确,请输入长度为6-20位的密码";
    }
    if (![NXInputChecker checkPassword:self.txtNewPassword.text]) {
        return @"新密码格式不正确,请输入长度为6-20位的密码";
    }
    if (![self.txtNewPassword.text isEqualToString:self.txtRepeatPassword.text]) {
        return @"两次输入密码不一致";
    }
    
    
    return nil;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length != 0 &&  textField.text.length + string.length > 20) {
        return NO;
    }
    return YES;
}
- (void)dealloc
{
    NSLog(@"changePasswordVC被销毁");
}
@end
