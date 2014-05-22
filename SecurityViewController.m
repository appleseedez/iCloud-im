//
//  SecurityViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "SecurityViewController.h"

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
        
        switch (indexPath.row) {
            case 0:
                if (isConnecting==0) {
                    [self checkSecurity];
                    isConnecting=1;
                }
                
                break;
            case 1:
                [self pushToChangePasswordView];
                break;
            default:
                break;
        
        
        }}
}
-(void)pushToChangePasswordView{
    
}
-(void)checkSecurity{
   //此处拽密保
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isConnecting=0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"passwordProtection" object:nil];
    
}
-(void)receive:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    isConnecting=0;
    if (isNormal) {
        if ([[notification.object objectForKey:@"code"]intValue]==222) {
            [self pushToSettingView];
        }
        else{
            [self pushToReSettingView:notification.object];
        }
    }
    else{
        [self errorAlert:[notification.userInfo objectForKey:@"reason"]];
    }
}
-(void)errorAlert:(NSString*)errorString{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"错误" message:errorString delegate:nil cancelButtonTitle:@"返回" otherButtonTitles: nil];
    [alert show];
}
-(void)pushToSettingView{
    UIStoryboard *story=self.storyboard;
   SecuretyQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyQuetionView"];
    
    
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
    
}
-(void)pushToReSettingView:(NSDictionary*)data{
    UIStoryboard *story=self.storyboard;
    SecuretyAnswerQuestionViewController *securetyQusetionVC= [story instantiateViewControllerWithIdentifier:@"SecuretyAnswerView"];
    securetyQusetionVC.data=data;
    [self.navigationController pushViewController:securetyQusetionVC animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
