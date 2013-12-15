//
//  NXRegViewController.m
//  social
//
//  Created by nsc on 13-11-6.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "NXRegViewController.h"
#import "RegManager.h"
#import "PersonRegButton.h"
@interface NXRegViewController ()
@property (weak, nonatomic) IBOutlet PersonRegButton *btnPersonReg;
@property (weak, nonatomic) IBOutlet PersonRegButton *btnPriseReg;

@end

@implementation NXRegViewController


- (IBAction)personalClicked:(UIButton *)sender {
    [RegManager defaultManager].regType=@"0";
}
- (IBAction)priceCLicked:(UIButton *)sender {
    [RegManager defaultManager].regType=@"1";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.btnPersonReg.normal=[UIColor colorWithRed:1 green:0.4 blue:0 alpha:1];
    self.btnPersonReg.high=[UIColor colorWithRed:1 green:0.6 blue:0.2 alpha:1];
    self.btnPriseReg.normal=[UIColor colorWithRed:0 green:0.4 blue:1 alpha:1];
    self.btnPriseReg.high=[UIColor colorWithRed:0.2 green:0.6 blue:1 alpha:1];
    [self.btnPriseReg setUI];
    [self.btnPersonReg setUI];
    self.btnPersonReg.logo.image=[UIImage imageNamed:@"reg_person"];
    self.btnPriseReg.logo.image=[UIImage imageNamed:@"reg_prise"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismiss) name:@"regSuccess" object:nil];
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
   
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   // self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"取消注册" style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
   }

-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
