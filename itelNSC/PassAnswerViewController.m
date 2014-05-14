//
//  PassAnswerViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-7.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassAnswerViewController.h"
#import "PassViewModel.h"
#import "PassResetViewController.h"
@interface PassAnswerViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbQuestion;
@property (weak, nonatomic) IBOutlet UITextField *txtAnswer;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@end

@implementation PassAnswerViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonUI];
    [self.passViewModel cgetRandomQuestion];
    __weak id weakSelf=self;
    //监听 hud
    [RACObserve(self, passViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong PassAnswerViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    //监听 随机问题
     [RACObserve(self, passViewModel.randomQuestion) subscribeNext:^(NSString *x) {
          __strong PassAnswerViewController *strongSelf=weakSelf;
         strongSelf.lbQuestion.text=x;
     }];
    //事件 提交回答
    [[self.btnNext rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
        __strong PassAnswerViewController *strongSelf=weakSelf;
        [strongSelf.passViewModel answerQuestion:strongSelf.txtAnswer.text];
    }];
    
    //监听 弹出修改密码页面
    [RACObserve(self, passViewModel.showModifyPassView) subscribeNext:^(NSNumber *x) {
        if ([x boolValue]) {
            __strong PassAnswerViewController *strongSelf=weakSelf;
            PassResetViewController *vc = [strongSelf.storyboard instantiateViewControllerWithIdentifier:@"PassReset"];
            vc.passViewModel=strongSelf.passViewModel;
            [strongSelf.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}
-(void)setButtonUI{
    [self.btnNext setClipsToBounds:YES];
    [self.btnNext.layer setCornerRadius:5.0];
}
- (void)dealloc
{
    NSLog(@"PassAnswer销毁");
}

@end
