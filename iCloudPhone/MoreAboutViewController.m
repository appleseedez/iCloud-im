//
//  MoreAboutViewController.m
//  iCloudPhone
//
//  Created by nsc on 14-3-4.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "MoreAboutViewController.h"
#import "ItelAction.h"
@interface MoreAboutViewController ()
@property (nonatomic) NSString *updateUrl;
@end

@implementation MoreAboutViewController

-(IBAction)checkNewVersion:(id)sender{
    
    [[ItelAction action] checkNewVersion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isNewVersion:) name:@"checkForNewVersion" object:nil];
}
-(void)isNewVersion:(NSNotification*)notification{
    if ((notification.userInfo!=nil)&[[notification.userInfo objectForKey:@"isNormal"]intValue]) {
        
    
        NSDictionary *mes=[notification.object objectForKey:@"data"];
        float sVersion=[[mes objectForKey:@"version"]floatValue];
        float lVersion=[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]floatValue];
        self.updateUrl = [mes objectForKey:@"update_url"];
        if (sVersion>lVersion) {
            NSString *message=[NSString stringWithFormat:@"最新版本为%.1f,\n您现在的版本是%.1f\n是否前往更新？",sVersion,lVersion];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"有版本更新" message:message delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"立即更新", nil];
            [alert show];
        }else{
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"目前版本已经是最新" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"目前版本已经是最新" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
    }
}
@end
