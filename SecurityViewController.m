//
//  SecurityViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityViewController.h"
#import "SecurityViewModel.h"
#import "SecuretyQuestionViewController.h"
#import "SecuretyAnswerQuestionViewController.h"
#import "SecurityViewModel.h"
@interface SecurityViewController ()

@end

@implementation SecurityViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.securtiViewModel=[[SecurityViewModel alloc]init];
    //监听hud
  __weak  id weakSelf=self;
    [RACObserve(self, securtiViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong SecurityViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    [RACObserve(self, securtiViewModel.questionData) subscribeNext:^(NSDictionary *x) {
        __strong SecurityViewController *strongSelf=weakSelf;
        if ([x isKindOfClass:[NSDictionary class]] ) {
            if ([x isEqual:@{}]) {
                [strongSelf pushToSettingView];
            }else{
                [strongSelf pushToReSettingView:x];
            }
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        
        switch (indexPath.row) {
            case 0:{
              
                    [self checkSecurity];
                
                }
                
                break;
            case 1:
                
                break;
            default:
                break;
        
        
        }}
}

-(void)checkSecurity{
   //此处拽密保
    
    [self.securtiViewModel getSecurity];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hideTabbar" object:nil];
    
}


-(void)pushToSettingView{
    UIStoryboard *story=self.storyboard;
   SecuretyQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyQuetionView"];
    securetyQusetionVC.securityViewModel=self.securtiViewModel;
    
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
    
}
-(void)pushToReSettingView:(NSDictionary*)data{
    UIStoryboard *story=self.storyboard;
    SecuretyAnswerQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyAnswerView"];
    securetyQusetionVC.data=data;
    securetyQusetionVC.securityViewModel=self.securtiViewModel;
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
