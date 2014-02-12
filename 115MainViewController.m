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
@interface _15MainViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtSearch;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"115MainPageBackground"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"115orangeColor"] forBarMetrics:UIBarMetricsDefault];
    UILabel *title=[[UILabel alloc]init];
    title.text = @"115 企业黄页";
    title.font=[UIFont fontWithName:@"HeiTi_SC" size:28];
    title.frame=CGRectMake(0, 0, 100, 40);
    title.textColor=[UIColor whiteColor];
    
    self.navigationItem.titleView=title;
	// Do any additional setup after loading the view.
}
- (IBAction)searchButtonClicked:(UIButton *)sender {
    NSString *search=self.txtSearch.text;
    if ([self checkInput:search]) {
        [[Manager115 defaultManager] search115:search];
    }
    
}

-(BOOL)checkInput:(NSString*)input{
    return YES;
}
@end
