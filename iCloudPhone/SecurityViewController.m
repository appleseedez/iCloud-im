//
//  SecurityViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityViewController.h"
#import "ItelAction.h"
#import "SecuretyQuestionViewController.h"
#import "SecuretyAnswerQuestionViewController.h"
@interface SecurityViewController ()

@end

@implementation SecurityViewController

static bool isConnecting=0;

- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==1) {
        if (isConnecting==0) {
            isConnecting=1;
        switch (indexPath.row) {
            case 0:
                [self checkSecurity];
                break;
            case 1:
                [self pushToChangePasswordView];
                break;
            default:
                break;
        }
        }
    }
}
-(void)pushToChangePasswordView{
    
}
-(void)checkSecurity{
    [[ItelAction action] checkOutProtection];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"passwordProtection" object:nil];
    
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    isConnecting=0;
    if (isNormal) {
        if ([notification.object isEqual:[NSNull null]]) {
            [self pushToSettingView];
        }
        else{
            [self pushToReSettingView:notification.object];
        }
    }
    else{
        [self errorAlert:@"网络不通"];
    }
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:errorString delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)pushToSettingView{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
   SecuretyQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyQuetionView"];
    
    
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
    
}
-(void)pushToReSettingView:(NSDictionary*)data{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    SecuretyAnswerQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyAnswerView"];
    securetyQusetionVC.data=data;
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
