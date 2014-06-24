//
//  MaoAppDelegate.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MaoAppDelegate.h"
#import "AppService.h"
#import "AddressService.h"
#import "IMService.h"
#import "SocketConnector.h"
@implementation MaoAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window.backgroundColor=[UIColor whiteColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       self.UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
                       
                   });
    [[NSNotificationCenter defaultCenter] addObserverForName:@"loginSuccess" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        NSMutableDictionary *info=[note.userInfo mutableCopy];
        for (NSString *k in [info allKeys] ) {
            id x= [info objectForKey:k];
            if ([x isEqual:[NSNull null]]) {
                
                [info setObject:@"" forKey:k];
            }
        }
        self.loginInfo=[info copy];
        
        [AppService defaultService].rootViewType=@(rootViewTypeMain);
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
             [[AddressService defaultService] loadAddressBook];
         });
               
    }];
     [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
//    [BPush setupChannel:launchOptions]; // 必须
//    
//    [BPush setDelegate:self]; // 必须。参数对象必须实现onMethod: response:方法，本示例中为self
//    
//    // [BPush setAccessToken:@"3.ad0c16fa2c6aa378f450f54adb08039.2592000.1367133742.282335-602025"];  // 可选。api key绑定时不需要，也可在其它时机调用
//    
//    [application registerForRemoteNotificationTypes:
//     UIRemoteNotificationTypeAlert
//     | UIRemoteNotificationTypeBadge
//     | UIRemoteNotificationTypeSound];
//    NSLog(@"appID:%@",[BPush getAppId]);
//    NSLog(@"channelID:%@",[BPush getChannelId]);
//    NSLog(@"userID:%@",[BPush getUserId]);
    return YES;
}
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    NSLog(@"tttt::%@",deviceToken);
//    [BPush registerDeviceToken:deviceToken]; // 必须
//    
//    [BPush bindChannel]; // 必须。可以在其它时机调用，只有在该方法返回（通过onMethod:response:回调）绑定成功时，app才能接收到Push消息。一个app绑定成功至少一次即可（如果access token变更请重新绑定）。
    NSLog(@"token:%@",deviceToken);
}
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Push Register Error:%@", err.description);
    
    
}
- (void) onMethod:(NSString*)method response:(NSDictionary*)data
{
//    if ([BPushRequestMethod_Bind isEqualToString:method])
//    {
////        NSDictionary* res = [[NSDictionary alloc] initWithDictionary:data];
//        
////        NSString *appid = [res valueForKey:BPushRequestAppIdKey];
////        NSString *userid = [res valueForKey:BPushRequestUserIdKey];
////        NSString *channelid = [res valueForKey:BPushRequestChannelIdKey];
////        int returnCode = [[res valueForKey:BPushRequestErrorCodeKey] intValue];
////        NSString *requestid = [res valueForKey:BPushRequestRequestIdKey];
//    }
}
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{     NSLog(@"收到啦 收到啦 \n");
    for (NSString * s  in [userInfo allKeys]) {
        NSLog(@"%@:%@\n",s ,[userInfo objectForKey:s]);
    }
//    [BPush handleNotification:userInfo]; // 可选
//    NSString *string=@"";
//    NSDictionary *aps=[userInfo objectForKey:@"aps"];
//    NSLog(@"你妹的 接到了\n");
//    for (NSString *s in aps.allKeys) {
//        
//        NSLog(@"%@:%@",s,[aps objectForKey:s]);
//        string=[NSString stringWithFormat:@"%@:%@\n",s,[aps objectForKey:s]];
//    }
//    
//    
//    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"你妹的 接到了" message:[userInfo description] delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles: nil ];
//    [alert show];
}
- (void)applicationWillResignActive:(UIApplication *)application
{   //[BPush unbindChannel];
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:6000000000 handler:^{}];
    if (backgroundAccepted)
    {
        [IMService defaultService].inBackground=@(YES);
        NSLog(@"VOIP backgrounding accepted");
    }
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [IMService defaultService].inBackground=@(NO);
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
