//
//  MoreAboutViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-3-4.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "MoreAboutViewController.h"
#import "ItelAction.h"
#import "IMManagerImp.h"
#import "NSCAppDelegate.h"
@interface MoreAboutViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lbVersion;
@property (weak, nonatomic) IBOutlet UIButton *btnCheckUpdate;
@property (weak, nonatomic) IBOutlet UIButton *btnGo;
@property (nonatomic) NSString *updateUrl;
@property (nonatomic,weak )  UIAlertView *go800alert;
@property (nonatomic,weak)  UIAlertView *updateAlert;

@end

@implementation MoreAboutViewController
- (IBAction)gotoJudge:(id)sender{
    NSString *str = [NSString stringWithFormat:
                     @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",APPID]; //appID 解释如下
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

-(IBAction)checkNewVersion:(id)sender{
    self.btnCheckUpdate.enabled=NO;
    [[ItelAction action] checkNewVersion:nil];
}
- (IBAction)call800:(id)sender {
   UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"要拨打8890人工热线吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];

    self.go800alert=alert;
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lbVersion.text=[NSString stringWithFormat:@"V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNewVersion:) name:@"checkForNewVersion" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
-(void)isNewVersion:(NSNotification*)notification{
    self.btnCheckUpdate.enabled=YES;
    if ((notification.userInfo!=nil)&[[notification.userInfo objectForKey:@"isNormal"]intValue]) {
        
       
        NSDictionary *mes=[notification.object objectForKey:@"data"];
        float sVersion=[[mes objectForKey:@"version"]floatValue];
        float lVersion=[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]floatValue];
        self.updateUrl = [mes objectForKey:@"update_url"];
        if (sVersion>lVersion) {
            NSString *message=[NSString stringWithFormat:@"最新版本为%.1f,\n您现在的版本是%.1f\n是否前往更新？",sVersion,lVersion];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"有版本更新" message:message delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"立即更新", nil];
            self.updateAlert=alert;
            [alert show];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"目前版本已经是最新" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"网络不通" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView==self.go800alert) {
        if (buttonIndex==1) {
            NSCAppDelegate *app=(NSCAppDelegate*)[UIApplication sharedApplication].delegate;
            [app.manager setIsVideoCall:NO];
            [app.manager  dial:@"8890"];
        }
        
        
    }else if(alertView==self.updateAlert){
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
    }
    }
}
@end
