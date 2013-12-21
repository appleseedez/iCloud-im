//
//  SecurityChangePasswordViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityChangePasswordViewController.h"
#import "RegNextButton.h"
#import "regDetailTextField.h"
#import "MBProgressHUD.h"
#import "NXInputChecker.h"
#define TXT_OLD_PASSWORD_TAG 510001
#define TXT_NEW_PASSWORD_TAG 510002
#define TXT_NEW_RE_PASSWORD_TAG 510003

@interface SecurityChangePasswordViewController ()
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) UIView *inputAccessoryView;
@end

@implementation SecurityChangePasswordViewController

static long currEditingTextTag=0;
static float animatedDuration=1.0;
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    currEditingTextTag=textField.tag;
}

-(UIView*)inputAccessoryView{
    if (_inputAccessoryView==nil) {
        _inputAccessoryView=[[UIView alloc]init];
        _inputAccessoryView.bounds=CGRectMake(0, 0, 320, 44);
        _inputAccessoryView.backgroundColor=[UIColor grayColor];
        UIButton *foreward=[[UIButton alloc]initWithFrame:CGRectMake(106, 0, 109, 44)];
        [foreward setTitle:@"下一个" forState:UIControlStateNormal];
        foreward.backgroundColor=[UIColor whiteColor];
        [foreward addTarget:self action:@selector(chanegeToNextText) forControlEvents:UIControlEventTouchUpInside];
        [foreward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_inputAccessoryView addSubview:foreward];
        
        UIButton *backward=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 105, 44)];
        [backward setTitle:@"上一个" forState:UIControlStateNormal];
        backward.backgroundColor=[UIColor whiteColor];
        [backward addTarget:self action:@selector(changeToLast) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:backward];
        [backward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIButton *end=[[UIButton alloc]initWithFrame:CGRectMake(216, 0, 106, 44)];
        [end setTitle:@"结束" forState:UIControlStateNormal];
        end.backgroundColor=[UIColor whiteColor];
        [end addTarget:self action:@selector(returnKeyBoard) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:end];
        [end setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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
-(void)setSubViewUI{
    [self.nextButton setUI];
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.txtNewPassword.inputAccessoryView=self.inputAccessoryView;
    self.txtOldPassword.inputAccessoryView=self.inputAccessoryView;
    self.txtRepeatPassword.inputAccessoryView=self.inputAccessoryView;
    
    [self.txtNewPassword setUI];
    [self.txtOldPassword setUI];
    [self.txtRepeatPassword setUI];
    [self.nextButton setUI];
    UIScrollView *scroll=self.scrollView;
    
    scroll.frame=self.view.frame;
    scroll.contentSize=scroll.bounds.size;

	// Do any additional setup after loading the view.
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
    [UIView animateKeyframesWithDuration:animatedDuration delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
        if (keyBoardHeightDelta>0) {
            scroll.frame=CGRectMake(0, 0, scroll.bounds.size.width, scroll.bounds.size.height-keyBoardHeightDelta);
            scroll.contentSize=self.view.bounds.size;
            scroll.contentOffset=CGPointMake(scroll.contentOffset.x, currTextY-scroll.bounds.size.height/2);
        }
        else{
            scroll.frame=self.view.frame ;
            scroll.contentOffset=CGPointMake(0,-54);
        }
    } completion:^(BOOL finished) {
        
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (IBAction)checkUserInput:(UIButton *)sender {
    [self returnKeyBoard];
    [self pushNextView];
    NSString *localCheck=[self checkInputFormat];
    if (localCheck==nil) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
    }
    else {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"验证失败" message:localCheck delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}
-(NSString*)checkInputFormat{
    
    if (![NXInputChecker checkPassword:self.txtOldPassword.text]) {
        return @"密码格式不正确";
    }
    if (![NXInputChecker checkPassword:self.txtNewPassword.text]) {
        return @"新密码格式不正确";
    }
    if (![self.txtNewPassword.text isEqualToString:self.txtRepeatPassword.text]) {
        return @"两次输入密码不一致";
    }
    
    
    return nil;
}
-(void)pushNextView{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"SecuretyMesView"];
    [self.navigationController pushViewController:vc animated:YES];
}
@end