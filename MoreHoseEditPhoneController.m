//
//  MoreHoseEditPhoneController.m
//  itelNSC
//
//  Created by nsc on 14-5-20.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreHoseEditPhoneController.h"
#import "MorePhoneViewModel.h"
#import "MoreMesViewController.h"
@interface MoreHoseEditPhoneController ()
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;

@end

@implementation MoreHoseEditPhoneController

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if (range.location>=11) {
        return NO;
    }
    else return YES;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.phoneViewModel = [[MorePhoneViewModel alloc]init];
    [self setButtonUI];
    //事件 点击按钮
    __weak id weakSelf=self;
    [[self.nextButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong MoreHoseEditPhoneController *strongSelf=weakSelf;
        [strongSelf.phoneViewModel checkPhoneNumber:strongSelf.txtPhone.text];
    }];
    //监听hud
    [RACObserve(self, phoneViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong MoreHoseEditPhoneController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    //监听 手机检查通过
      [RACObserve(self, phoneViewModel.checkPassed) subscribeNext:^(NSNumber *x) {
          __strong MoreHoseEditPhoneController *strongSelf=weakSelf;
          if ([x boolValue]) {
              UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"即将给您的手机发送一条确验证信" message:nil delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
              [alert show];
              [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
                  if ([x integerValue]==1) {
                      [strongSelf.phoneViewModel sendMessage];
                      return ;
                      
                     
                      
                  }
              }];
          }
      }];
    //监听 定时器
      [RACObserve(self, phoneViewModel.startTimer) subscribeNext:^(NSNumber *x) {
          if ([x boolValue]) {
               __strong MoreHoseEditPhoneController *strongSelf=weakSelf;
              MoreMesViewController *mesVC=[strongSelf.storyboard instantiateViewControllerWithIdentifier:@"moreMesView"];
              mesVC.phoneViewModel=strongSelf.phoneViewModel;
              [strongSelf.navigationController pushViewController:mesVC animated:YES];
          }
      }];
}
-(void)setButtonUI{
    [self.nextButton setClipsToBounds:YES];
    [self.nextButton.layer setCornerRadius:5.0];
}
-(void)dismiss{
     [self.navigationController dismissViewControllerAnimated:YES completion:^{
         
     }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)dealloc{
    NSLog(@"MoreHostEditPhone被成功销毁");
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
