//
//  SecuretyQuestionViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecuretyQuestionViewController.h"
#import "SecurityViewModel.h"
#import "NXInputChecker.h"
#define TXT_Q1 870021
#define TXT_A1 870022
#define TXT_Q2 870023
#define TXT_A2 870024
#define TXT_Q3 870025
#define TXT_A3 870026
@interface SecuretyQuestionViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *question1;

@property (weak, nonatomic) IBOutlet UITextField *answer1;
@property (weak, nonatomic) IBOutlet UITextField *question2;
@property (weak, nonatomic) IBOutlet UITextField *answer2;
@property (weak, nonatomic) IBOutlet UITextField *question3;
@property (weak, nonatomic) IBOutlet UITextField *answer3;
@property (strong,nonatomic) UIView *inputAccessoryView;
@end

@implementation SecuretyQuestionViewController
static long currEditingTextTag=0;

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
        [foreward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [foreward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
        [_inputAccessoryView addSubview:foreward];
        
        UIButton *backward=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 105, 44)];
        [backward setTitle:@"上一个" forState:UIControlStateNormal];
        backward.backgroundColor=[UIColor whiteColor];
        [backward addTarget:self action:@selector(changeToLast) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:backward];
        [backward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [backward setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
        [backward setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        UIButton *end=[[UIButton alloc]initWithFrame:CGRectMake(216, 0, 106, 44)];
        [end setTitle:@"结束" forState:UIControlStateNormal];
        end.backgroundColor=[UIColor whiteColor];
        [end addTarget:self action:@selector(returnKeyBoard) forControlEvents:UIControlEventTouchUpInside];
        [_inputAccessoryView addSubview:end];
        [end setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_normal"] forState:UIControlStateNormal];
        [end setBackgroundImage:[UIImage imageNamed:@"Register_input_accessory_high"] forState:UIControlStateHighlighted];
        [end setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _inputAccessoryView;
}
-(void)chanegeToNextText{
    UITextField *text=nil;
    float nextTag=0;
    if (currEditingTextTag==TXT_A3) {
        nextTag=TXT_Q1;
    }
    else{
        nextTag=currEditingTextTag+1;
    }
    
    text=(UITextField*)[self.view viewWithTag:nextTag];
    [text becomeFirstResponder];
}
-(void)changeToLast{
    UITextField *last=nil;
    float nextTag=0;
    
    if (currEditingTextTag==TXT_Q1) {
        nextTag=TXT_A3;
    }
    else{
        nextTag=currEditingTextTag-1;
    }
    
    last=(UITextField*)[self.view viewWithTag:nextTag];
    [last becomeFirstResponder];
}
-(void)returnKeyBoard{
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     
    self.question1.inputAccessoryView=self.inputAccessoryView;
    self.question2.inputAccessoryView=self.inputAccessoryView;
    self.question3.inputAccessoryView=self.inputAccessoryView;
    self.answer1.inputAccessoryView=self.inputAccessoryView;
    self.answer2.inputAccessoryView=self.inputAccessoryView;
    self.answer3.inputAccessoryView=self.inputAccessoryView;
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(finishClicked)];
    
    [[RACObserve(self, securityViewModel.modifySuccess) map:^id(id value) {
        if ([value boolValue]) {
             [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
       
        return value;
    }] subscribeNext:^(id x) {
        
    }];
    
}
-(void)finishClicked{
    NSString *check=[self checkInput];
    if (check==nil) {
        NSDictionary *parameters=@{@"question1": self.question1.text,
                                   @"question2": self.question2.text,
                                   @"question3": self.question3.text,
                                   @"answer1":self.answer1.text,
                                   @"answer2":self.answer2.text,
                                   @"answer3":self.answer3.text,
                                   };
        
        //这里提交密保
        [self.securityViewModel modifyProtection:parameters];
    }
    else{
        [[[UIAlertView alloc]initWithTitle:check message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}


-(NSString*)checkInput{
    if ( self.question1.text.length>20||self.question2.text.length>20||self.question3.text.length>20||self.answer1.text.length>20||self.answer2.text.length>20||self.answer3.text.length>20) {
          return @"请输入少于20个汉字的问题和答案";
    }
    return nil;
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.length != 0 &&  textField.text.length + string.length > 15) {
        return NO;
    }
    return YES;
}
@end
