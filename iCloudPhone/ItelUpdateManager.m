//
//  ItelUpdateManager.m
//  iCloudPhone
//
//  Created by nsc on 14-3-5.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelUpdateManager.h"
#import "ItelAction.h"
static ItelUpdateManager *instance;
@implementation ItelUpdateManager

+(ItelUpdateManager*)defaultManager{
    return instance;
}
+(void)initialize{
    if (instance==nil) {
        instance=[[ItelUpdateManager alloc]init];
        [instance addNotification];
    }
}
-(void)checkUpdate{
    [[ItelAction action] checkNewVersion:nil];
}
-(void)addNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importantUpdate:) name:@"checkForNewVersion" object:nil];
}
-(void)importantUpdate:(NSNotification*)notification{
    if (notification.userInfo) {
        int isNormal = [[notification.userInfo objectForKey:@"isNormal"]integerValue];
        if (isNormal) {
            NSDictionary *mes=[notification.object objectForKey:@"data"];
            BOOL updateLevel=[[mes objectForKey:@"update_level"]boolValue];
            float sVersion=[[mes objectForKey:@"version"]floatValue];
            float lVersion=[[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]floatValue];
            
            if ((updateLevel==YES)&(sVersion>lVersion)) {
                self.updateUrl=[mes objectForKey:@"update_url"];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"重要更新" message:@"您的iTel版本过旧,请更新最新版本之后继续使用" delegate:self cancelButtonTitle:@"立即更新" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
}
@end
