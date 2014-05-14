//
//  RegDetailViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RegDetailViewController.h"
#import "LoginViewModel.h"
#import "RegisterViewModel.h"
#import "RegMesViewController.h"
#import "RegChooseNumberViewController.h"
#define TXT_ITEL_TAG 500001
#define TXT_PASSWORD_TAG 500002
#define TXT_RE_PASSWORD_TAG 500003
#define TXT_PHONE_NUMBER_TAG 500004
@interface RegDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtItel;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRePassword;
@property (weak, nonatomic) IBOutlet UITextField *txtPhoneNumber;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *tipView;
@property (weak, nonatomic) IBOutlet UIButton *btnXuan;

@property (strong,nonatomic) UIView *inputAccessoryView;
@end

@implementation RegDetailViewController
static long currEditingTextTag=0;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.regViewModel=[[RegisterViewModel alloc]init];
    [self setTipUI];
    self.txtItel.inputAccessoryView=self.inputAccessoryView;
    self.txtPassword.inputAccessoryView=self.inputAccessoryView;
    self.txtRePassword.inputAccessoryView=self.inputAccessoryView;
    self.txtPhoneNumber.inputAccessoryView=self.inputAccessoryView;
    [self setTextFieldUI:self.txtItel];
     [self setTextFieldUI:self.txtPassword];
     [self setTextFieldUI:self.txtRePassword];
     [self setTextFieldUI:self.txtPhoneNumber];
    UIScrollView *scroll=self.scrollView;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    scroll.frame=self.view.frame;
    scroll.contentSize=scroll.frame.size;
    self.regViewModel.type=self.viewModel.regType;
    
    [self.nextButton setClipsToBounds:YES];
    [self.nextButton.layer setCornerRadius:5];
    __weak id weakSelf=self;
    //监听 格式错误信息
    [RACObserve(self, regViewModel.regError) subscribeNext:^(NSString *x) {
      
        
        if (x) {
            [[[UIAlertView alloc]initWithTitle:x message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    }];
    //监听hud
    [RACObserve(self, regViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong  RegDetailViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
               hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    //监听 用户选择的号码
     [RACObserve(self, regViewModel.selectedItel) subscribeNext:^(NSString *x) {
         __strong  RegDetailViewController *strongSelf=weakSelf;
         if ([x length]) {
             strongSelf.txtItel.text=x;
         }
     }];
    
    
    //事件 下一步按钮
    [[self.nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong  RegDetailViewController *strongSelf=weakSelf;
        strongSelf.regViewModel.itel=strongSelf.txtItel.text;
        strongSelf.regViewModel.password=strongSelf.txtPassword.text ;
        strongSelf.regViewModel.repassword=strongSelf.txtRePassword.text;
        strongSelf.regViewModel.phone=strongSelf.txtPhoneNumber.text;
        if (![strongSelf.regViewModel checkInput]) {
            return ;
        }else{
            [strongSelf.regViewModel checkItel];
        }
    }];
     //监听 push短信页面
    [RACObserve(self, regViewModel.startTimer) subscribeNext:^(NSNumber *x) {
        __strong  RegDetailViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            [strongSelf pushMes];
        }
    }];
    
    
}
-(void)setTipUI{
    UIColor *borderColor=[UIColor colorWithRed:0.875 green:0.698 blue:0.447 alpha:1];
    
    
    
    UIColor *backColor=[UIColor colorWithRed:1 green:0.91 blue:0.78 alpha:1];
    [self.tipView.layer setBorderColor:borderColor.CGColor];
    
    [self.tipView setBackgroundColor:backColor];
    [self.tipView.layer setBorderWidth:1];
}
-(void)setTextFieldUI:(UITextField*)textField{
    [textField.layer setBorderWidth:1];
    [textField.layer setBorderColor:[UIColor colorWithRed:0.8888 green:0.8888 blue:0.8888 alpha:1].CGColor];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length>0) {
        
        if (textField==self.txtItel) {
            if (textField.text.length>=11) {
                return NO;
            }
            else return YES;
        }
        else if(textField==self.txtPassword){
            if (textField.text.length>=20) {
                return NO;
            }
            else return YES;
        }
        else if(textField==self.txtRePassword){
            if (textField.text.length>=20) {
                return NO;
            }
            else return YES;
        }
        else if(textField==self.txtPhoneNumber){
            if (textField.text.length>=11) {
                return NO;
            }
            else return YES;
        }
    }
    return YES;
}
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
        case TXT_ITEL_TAG:
            nextTag=TXT_PASSWORD_TAG;
            break;
        case TXT_PASSWORD_TAG:
            nextTag=TXT_RE_PASSWORD_TAG;
            break;
        case TXT_RE_PASSWORD_TAG:
            nextTag=TXT_PHONE_NUMBER_TAG;
            break;
        case TXT_PHONE_NUMBER_TAG:
            nextTag=TXT_ITEL_TAG;
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
        case TXT_PASSWORD_TAG:
            nextTag=TXT_ITEL_TAG;
            break;
        case TXT_RE_PASSWORD_TAG:
            nextTag=TXT_PASSWORD_TAG;
            break;
        case TXT_PHONE_NUMBER_TAG:
            nextTag=TXT_RE_PASSWORD_TAG;
            break;
        case TXT_ITEL_TAG:
            nextTag=TXT_PHONE_NUMBER_TAG;
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
            scroll.frame=self.view.frame ;
            scroll.contentOffset=CGPointMake(0,-54);
        }
    } completion:^(BOOL finished) {
        
    }];
}
-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
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
-(void)pushMes{
    if ([self.navigationController.childViewControllers lastObject]==self) {
        RegMesViewController *mesVC=  [self.storyboard instantiateViewControllerWithIdentifier:@"RegMesView"];
        mesVC.regViewModel=self.regViewModel;
        [self.navigationController pushViewController:mesVC animated:YES];
    }
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[RegChooseNumberViewController class]]){
        ((RegChooseNumberViewController*)segue.destinationViewController).regViewModel=self.regViewModel;
    }
}
-(void)dealloc{
    NSLog(@"regDetailVC被销毁");
}

@end
