//
//  RegChooseNumberViewController.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RegChooseNumberViewController.h"
#import "RegisterViewModel.h"

@interface RegChooseNumberViewController ()
@property (nonatomic) NSMutableArray *subButtons;
@end

@implementation RegChooseNumberViewController

static float leftX=5.0;
static float rightX=165.0;
static float topY=70.0;
static float height=40.0;
static float width=150.0;
static float side=5.0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.subButtons=[NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"换一组" style:UIBarButtonItemStylePlain target:self action:@selector(change)];
    for (int i=0; i<16; i++) {
        float btnX;
        if (i%2==1) {
            btnX=leftX;
        }else{
            btnX=rightX;
        }
        float btnY=i/2 *(height+side)+topY;
        UIButton *btn=[UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame=CGRectMake(btnX, btnY, width, height);
        btn.backgroundColor=[UIColor whiteColor];
        btn.titleLabel.text=@"";
        [btn setTitle:@"" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(numberChoosed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        [self.subButtons addObject:btn];
    }
    
    [self.regViewModel getRandomNumbers];
    __weak id weakSelf=self;
    //监听 busy
    [RACObserve(self, regViewModel.busy) subscribeNext:^(NSNumber *x) {
       __strong RegChooseNumberViewController *strongSelf=weakSelf;
        if ([x boolValue]) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后...";
        }else {
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    
    //监听 datasource
    [RACObserve(self, regViewModel.randomNumbersDataSource)subscribeNext:^(NSArray *x) {
         __strong RegChooseNumberViewController *strongSelf=weakSelf;
        for (UIButton *btn in strongSelf.subButtons) {
            NSInteger i= [strongSelf.subButtons indexOfObject:btn];
            NSString *number=[x objectAtIndex:i];
            [btn setTitle:number forState:UIControlStateNormal];
            btn.titleLabel.text=number;
        }
    }];
    
}
-(void)numberChoosed:(UIButton*)sender{
    
    NSString *number= sender.titleLabel.text;
    if (number.length) {
        self.regViewModel.selectedItel=number;
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSLog(@"%@",number);
}
-(void)change{
    [self.regViewModel getRandomNumbers];
}
- (void)dealloc
{
    NSLog(@"regChooseVC被销毁");
}
@end
