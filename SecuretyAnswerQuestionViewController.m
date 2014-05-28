//
//  SecuretyAnswerQuestionViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-26.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecuretyAnswerQuestionViewController.h"

#import "SecurityViewModel.h"

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
    
    [[RACObserve(self, securityViewModel.answerPassed) map:^id(NSNumber *value) {
        if ([value boolValue]) {
            [self pushNext];
            
        }
        return value;
    }]subscribeNext:^(id x) {
        
    }];
	// Do any additional setup after loading the view.
}
- (IBAction)nextButtonPushed:(UIButton *)sender {
    [self.securityViewModel checkAnswer:self.strQuestion answer:self.txtAnswer.text];
    
}

-(void)pushNext{
    UIStoryboard *story=self.storyboard;
    SecuretyQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyQuetionView"];
    securetyQusetionVC.securityViewModel=self.securityViewModel;
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
}


@end
