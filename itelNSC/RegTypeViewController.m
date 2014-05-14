//
//  RegTypeViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RegTypeViewController.h"
#import "LoginViewModel.h"
#import "RegDetailViewController.h"
@interface RegTypeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnPerson;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;

@end

@implementation RegTypeViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    [self.btnPerson setClipsToBounds:YES];
    [self.btnPrice setClipsToBounds:YES];
    [self.btnPerson.layer setCornerRadius:5];
    [self.btnPrice.layer setCornerRadius:5];
    __weak id weakSelf=self;
    [[self.btnPrice rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong RegTypeViewController *strongSelf=weakSelf;
        strongSelf.viewModel.regType=@(1);
    }];
    [[self.btnPerson rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        __strong RegTypeViewController *strongSelf=weakSelf;
        strongSelf.viewModel.regType=@(0);
    }];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    ((RegDetailViewController*)segue.destinationViewController).viewModel=self.viewModel;
}
- (void)dealloc
{
    NSLog(@"regTypeVC被成功销毁");
}

@end
