//
//  SecuretyQuestiongViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PassSecuretyQuestiongViewController.h"
#import "RegNextButton.h"
#import "PassManager.h"
#import "regDetailTextField.h"
#import "PassResetViewController.h"
#import "RegNextButton.h"
@interface PassSecuretyQuestiongViewController ()

@property (weak, nonatomic) IBOutlet UILabel *question;
@property (weak, nonatomic) IBOutlet RegNextButton *nextButton;

@property (weak, nonatomic) IBOutlet regDetailTextField *txtAnswer;
@property (nonatomic,strong) NSString *strQuestion;
@end

@implementation PassSecuretyQuestiongViewController


-(void)startHud{
    self.nextButton.enabled=NO;
}
-(void)stopHud{
    self.nextButton.enabled=YES;
}
-(void)setUI{
    [self.nextButton setUI];
    [self.txtAnswer setUI];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    int i = arc4random()%3;
    NSDictionary *data = [PassManager defaultManager].questions;
    switch (i) {
        case 0:
            self.strQuestion=[data objectForKey:@"question1"];
            break;
        case 1:
            self.strQuestion=[data objectForKey:@"question2"];
            break;
        case 2:
            self.strQuestion=[data objectForKey:@"question3"];
            break;
            
        default:
            break;
    }
    self.question.text=[NSString stringWithFormat:@"问题：%@",self.strQuestion];
    
	// Do any additional setup after loading the view.
}
- (IBAction)nextButtonPushed:(RegNextButton *)sender {
    [self startHud];
    [[PassManager defaultManager] answerQuestion:self.strQuestion answer:self.txtAnswer.text];
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"] boolValue];
    [self stopHud];
    if (isNormal) {
        [self pushNext];
    }
    else{
        [self errorAlert:[notification.userInfo objectForKey:@"reason"]];
    }
}
-(void)pushNext{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
   PassResetViewController *passResetVC= [story instantiateViewControllerWithIdentifier:@"passReset"];
    [self.navigationController pushViewController:passResetVC animated:YES];
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"回答错误" message:errorString delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"passAnswerQuestion" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
