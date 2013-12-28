//
//  SecuretyQuestionViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecuretyQuestionViewController.h"
#import "ItelAction.h"
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
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishClicked)];
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
        [[ItelAction action] modifySecuretyProduction:parameters];
    }
    else{
        [self errorAlert:check];
    }
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    if (isNormal) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜设置成功" message:@"请牢记您的密保问题和答案" delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil];
        [alert show];
    }
    else {
        [self errorAlert:@"设置失败 请稍后重试"];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"输入错误" message:errorString delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}

-(NSString*)checkInput{
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"modifySecurety" object:nil];
   [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(conformKeyBoard:) name:UIKeyboardWillChangeFrameNotification object:Nil];
}
-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
