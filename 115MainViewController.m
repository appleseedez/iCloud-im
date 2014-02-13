//
//  115MainViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "115MainViewController.h"
#import "Manager115.h"
#import "List115ViewController.h"
#import "Button115.h"
#import "IMCallingViewController.h"
#import "NSCAppDelegate.h"
#import "IMDailViewController.h"
#import "NXInputChecker.h"
@interface _15MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIButton *btnSearch;
@property (weak, nonatomic) IBOutlet Button115 *personButton;

@end

@implementation _15MainViewController
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
- (IBAction)dismis:(UIBarButtonItem *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)goForewardStep:(id)userInfo{
    NSArray *arr=[userInfo objectForKey:@"list"];
    List115ViewController *listVC=[self.storyboard instantiateViewControllerWithIdentifier:@"list115"];
    if (listVC) {
        listVC.arrList=arr;
        [self.navigationController pushViewController:listVC animated:YES];
    }
    
    
}
-(NSArray*)notifications{
    return @[@"115search"];
}
- (void) presentCallingView{

    //加载“拨号中”界面
    //加载stroyboard
    NSCAppDelegate *delegate=(NSCAppDelegate*)[UIApplication sharedApplication].delegate ;
    [delegate.manager dial:@"115"];
    
    
    
    
}

-(void)setUI{
    [self.personButton setUI];
    [self.btnSearch.layer setCornerRadius:5];
    [self.btnSearch setClipsToBounds:YES];
    [self.txtSearch.layer setCornerRadius:5];
    [self.txtSearch.layer setBorderWidth:1.5];
    [self.txtSearch.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.txtSearch setClipsToBounds:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUI];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"115MainPageBackground"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"115orangeColor"] forBarMetrics:UIBarMetricsDefault];
    UILabel *title=[[UILabel alloc]init];
    title.text = @"115 企业黄页";
    title.font=[UIFont fontWithName:@"HeiTi_SC" size:28];
    title.frame=CGRectMake(0, 0, 100, 40);
    title.textColor=[UIColor whiteColor];
    [self.personButton addTarget:self action:@selector(presentCallingView) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView=title;
	// Do any additional setup after loading the view.
}
- (IBAction)searchButtonClicked:(UIButton *)sender {
    NSString *search=self.txtSearch.text;
    [self.view endEditing:YES];
    if ([self checkInput:search]) {
        [[Manager115 defaultManager] search115:search];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"请输入搜索内容" message:@"搜索内容不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
    
}

-(BOOL)checkInput:(NSString*)input{
    return [NXInputChecker checkEmpty:input];
}
@end
