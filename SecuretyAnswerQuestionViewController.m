//
//  SecuretyAnswerQuestionViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-26.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecuretyAnswerQuestionViewController.h"



#import "SecuretyQuestionViewController.h"
@interface SecuretyAnswerQuestionViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *txtAnswer;
@property (nonatomic,strong) NSString *strQuestion;
@property (weak, nonatomic) IBOutlet UILabel *question;

@end

@implementation SecuretyAnswerQuestionViewController

-(void)setUI{
    [self.nextButton setClipsToBounds:YES];
    [self.nextButton.layer setCornerRadius:5.0];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"回答问题"];
    [self setUI];
    int i = arc4random()%3;

    switch (i) {
        case 0:
            self.strQuestion=[self.data objectForKey:@"question1"];
            break;
        case 1:
            self.strQuestion=[self.data objectForKey:@"question2"];
            break;
        case 2:
            self.strQuestion=[self.data objectForKey:@"question3"];
            break;
            
        default:
            break;
    }
    self.question.text=[NSString stringWithFormat:@"问题：%@",self.strQuestion];
    
	// Do any additional setup after loading the view.
}
- (IBAction)nextButtonPushed:(UIButton *)sender {
    
    
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        [self pushNext];
    }
    else{
        [self errorAlert:@"密保问题回答错误"];
    }
}
-(void)pushNext{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    SecuretyQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyQuetionView"];
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"回答错误" message:errorString delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"answerQuestion" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
