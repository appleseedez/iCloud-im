//
//  NSCAppDelegate.m
//  iCloudPhone
//
//  Created by nsc on 13-11-14.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "NSCAppDelegate.h"
#import "RootViewController.h"
#import "ItelBookManager.h"
#import "ContentViewController.h"
#import "NXLoginViewController.h"
#import "ItelNetManager.h"
#import "ItelUserManager.h"
#import "IMCoreDataManager.h"
#import "IMManagerImp.h"
#import "ItelMessageManager.h"

#define winFrame [UIApplication sharedApplication].delegate.window.bounds
@implementation NSCAppDelegate
-(void) signOut{
    [[ItelAction action] logout];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"currUser"];
    //[self tearDownManagers];
    [self changeRootViewController:RootViewControllerLogin userInfo:nil];
    
}
-(void)tearDownManagers{
    [[ItelMessageManager defaultManager] tearDown];
    [[ItelUserManager defaultManager] tearDown];
    [[ItelBookManager defaultManager] tearDown];
    [[ItelNetManager defaultManager] tearDown];
    [self setupManagers];

}
-(void)setupManagers{
    [ItelMessageManager defaultManager];
    [ItelUserManager defaultManager];
    [ItelBookManager defaultManager];
    [ItelNetManager defaultManager];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"signOut" object:nil];
    [self setupManagers];
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    RootViewController *rootVC=[mainStoryboard instantiateViewControllerWithIdentifier:@"rootVC"];
    self.manager = [[IMManagerImp alloc] init];
    //[self.manager setup];
    rootVC.manager=self.manager;
    self.RootVC=rootVC;
    [rootVC setSelectedIndex:2];
    
   //===========================登陆注册=============================
    UIStoryboard *loginStoryboard=[UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
    
    NXLoginViewController *loginVC=[loginStoryboard instantiateViewControllerWithIdentifier:@"login"];
    self.loginVC=loginVC;
    
    [self checkAutoLogin];
    
   [[ItelBookManager defaultManager] phoneBook];
    
    if (self.autoLogin) {
        [self.window setRootViewController:rootVC];
    }
    else {
        [self.window setRootViewController:loginVC];
        
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
   return YES;
}
-(void)checkAutoLogin{
     //查询currUser
     HostItelUser *currUser=nil;
    NSString *hostItel=[[NSUserDefaults standardUserDefaults]objectForKey:@"currUser"];
    if (![hostItel isEqualToString:@"0"]) {
        IMCoreDataManager *manager=[IMCoreDataManager defaulManager];
        
        NSFetchRequest* getHost = [NSFetchRequest fetchRequestWithEntityName:@"HostItelUser"];
        getHost.sortDescriptors = @[];
        NSArray* host = [[manager managedObjectContext] executeFetchRequest:getHost error:nil];
        if (host) {
            for(HostItelUser *user in host){
                if ([user.itelNum isEqualToString:hostItel]) {
                    currUser=user;
                }
            }
        }
    }
   
    if (currUser==nil) {
        self.autoLogin=0;
    }
    else{ //自动登陆
        self.autoLogin=1;
        [[ItelAction action] setHostItelUser:currUser];
        NSDictionary* params = @{
                                 ROUTE_SERVER_IP_KEY:currUser.domain,
                                 ROUTE_SERVER_PORT_KEY:currUser.port,
                                 HOST_ITEL_NUMBER:currUser.itelNum
                                 };

        [self setupIMManager:params];
        
//        [self readStoredCookies];
    }
}
//-(void)saveStoredCookies
//{
//    NSURL* hostDomain = [NSURL URLWithString: @"211.149.144.15"];
//    
//    NSArray *httpCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hostDomain];
//    NSData *httpCookiesData = [NSKeyedArchiver archivedDataWithRootObject:httpCookies];
//    [[NSUserDefaults standardUserDefaults] setObject:httpCookiesData forKey:@"savedHttpCookies"];
////    
////    NSArray *httpsCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hostDomain];
////    NSData *httpsCookiesData = [NSKeyedArchiver archivedDataWithRootObject:httpsCookies];
////    [[NSUserDefaults standardUserDefaults] setObject:httpsCookiesData forKey:@"savedHttpsCookies"];
//    
//    [[NSUserDefaults standardUserDefaults] synchronize];
//}

//-(void)readStoredCookies
//{
//    //clear, read and install stored cookies
//    NSURL* hostDomain = [NSURL URLWithString: @"211.149.144.15"];
//    
//    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hostDomain];
//    for (NSHTTPCookie *cookie in cookies) {
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
//    }
////    cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:hostDomain];
////    for (NSHTTPCookie *cookie in cookies) {
////        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
////    }
//    
//    NSData *httpCookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedHttpCookies"];
//    if([httpCookiesData length]) {
//        NSArray *savedCookies = [NSKeyedUnarchiver unarchiveObjectWithData:httpCookiesData];
//        for (NSHTTPCookie *cookie in savedCookies) {
//            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//        }
//    }
//    
//    for (NSHTTPCookie* c in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//        NSLog(@"cookie:%@",c);
//    }
////    NSData *httpsCookiesData = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedHttpsCookies"];
////    if([httpsCookiesData length]) {
////        NSArray *savedCookies = [NSKeyedUnarchiver unarchiveObjectWithData:httpsCookiesData];
////        for (NSHTTPCookie *cookie in savedCookies) {
////            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
////        }
////    }
//}



-(void)changeRootViewController:(setRootViewController)Type userInfo:(NSDictionary *)info{
    [UIView beginAnimations:@"memory" context:nil];
    if (Type==RootViewControllerLogin) {
        [self.window setRootViewController:self.loginVC];
        [self.manager tearDown];
        [self.manager disconnectToSignalServer];
        [self.manager setMyAccount:nil];
        self.RootVC.view=nil;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rootViewDisappear" object:nil];
    }
    else if(Type==RootViewControllerMain){
        [self.window setRootViewController:self.RootVC];
        NSString *hostItel=[[ItelAction action]getHost].itelNum;
        [[NSUserDefaults standardUserDefaults] setObject:hostItel forKey:@"currUser"];
        NSDictionary* params = @{
                                 ROUTE_SERVER_IP_KEY:[info valueForKey:ROUTE_SERVER_IP_KEY],
                                 ROUTE_SERVER_PORT_KEY:[info valueForKey:ROUTE_SERVER_PORT_KEY],
                                 HOST_ITEL_NUMBER:hostItel
                                 };

        [self setupIMManager:params];
        [self.manager setup];
        [self.manager connectToSignalServer];
        self.loginVC.view=nil;
    }
    [UIView commitAnimations];
//    [self saveStoredCookies];
}

- (void) setupIMManager:(NSDictionary*) params{
    if ([[params allKeys] count] == 3) {
        [self.manager setRouteSeverIP:[params valueForKey:ROUTE_SERVER_IP_KEY]];
        [self.manager setRouteServerPort:[[params valueForKey:ROUTE_SERVER_PORT_KEY] intValue]];
        [self.manager setMyAccount:[params valueForKey:HOST_ITEL_NUMBER]];

    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillResignActive");
#endif
    
    [self.manager tearDown];
//    [self.manager disconnectToSignalServer];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationDidEnterBackground");
#endif
     
//    [self.manager tearDown];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillEnterForeground ");
#endif
//    if ([[ItelAction action] getHost]) {
//        [self.manager setup];
//    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationDidBecomeActive ");
#endif
//     if ([[ItelAction action] getHost]) {
////    [self.manager connectToSignalServer];
//     }
    
    if ([[ItelAction action] getHost]) {
        [self.manager setup];
        [self.manager connectToSignalServer];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillTerminate");
#endif
    [self.manager tearDown];
}

@end
