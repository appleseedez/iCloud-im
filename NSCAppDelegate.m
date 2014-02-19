//
//  NSCAppDelegate.m
//  iCloudPhone
//
//  Created by nsc on 13-11-14.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "NSCAppDelegate.h"
#import "RootViewController.h"
#import "ContentViewController.h"
#import "NXLoginViewController.h"
#import "IMManagerImp.h"
#import "ItelMessageInterfaceImp.h"
#import "ItelAction.h"
#import "IMCoreDataManager+FMDB_TO_COREDATA.h"
#define winFrame [UIApplication sharedApplication].delegate.window.bounds

@interface ItelMessageInterfaceImp()
+ (instancetype) defaultMessageInterface;
-(void) setup;
-(void) tearDown;
@end

@implementation NSCAppDelegate
-(void) signOut{
    [[ItelAction action] logout];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"currUser"];

    [self.manager logoutFromSignalServer];
    [self.manager tearDown];
    [self changeRootViewController:RootViewControllerLogin userInfo:nil];
    [self.manager clearTable];
}


- (void) reconnect:(NSNotification*) notify{

    if (self.manager && ![[self.manager myAccount] isEqualToString: BLANK_STRING]) {
#if usertip
        [[IMTipImp defaultTip] showTip:@"开始重连"];
#endif
        [self.manager connectToSignalServer];
    }

}

-(void)setupManagers{

}


- (void) registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signOut) name:@"signOut" object:nil];
    //绑定重连通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnect:) name:RECONNECT_TO_SIGNAL_SERVER_NOTIFICATION object:nil];
}
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (self.phoneBook == nil) {
        self.phoneBook = [[AddressBook alloc] init];
        [self.phoneBook loadAddressBook];
    }
    [[IMCoreDataManager defaulManager] isAreaInCoreData]; //地名插入coredata
    [self setupManagers];
    //初始化ItelMessageInterface
    [ItelMessageInterfaceImp defaultMessageInterface];

    RootViewController *rootVC= (RootViewController*) self.window.rootViewController;
    self.manager = [[IMManagerImp alloc] init];
    [self.manager setup];
    [self registerNotifications];
    [[ItelMessageInterfaceImp defaultMessageInterface] setup];
    rootVC.manager=self.manager;
    self.RootVC=rootVC;
   
    
   //===========================登陆注册=============================
    UIStoryboard *loginStoryboard=[UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];
    
    NXLoginViewController *loginVC=[loginStoryboard instantiateViewControllerWithIdentifier:@"login"];
    self.loginVC=loginVC;
    
    [self checkAutoLogin];
    
//   [[ItelBookManager defaultManager] phoneBook];
    
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
                                 kDomain:currUser.domain,
                                 kPort:currUser.port,
                                 kHostItelNumber:currUser.itelNum
                                    };
        [[ItelAction action] checkAddressBookMatchingItel];
        [self setupIMManager:params];
        if ([[ItelAction action] getHost]) {
//            [self.manager setup];
            [self.manager connectToSignalServer];
        }
        
    }
}




-(void)changeRootViewController:(setRootViewController)Type userInfo:(NSDictionary *)info{
    [UIView beginAnimations:@"memory" context:nil];
    if (Type==RootViewControllerLogin) {
        [self.window setRootViewController:self.loginVC];
        [self.manager tearDown];
        [self.manager disconnectToSignalServer];
        [self.manager setMyAccount:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"rootViewDisappear" object:nil];
    }
    else if(Type==RootViewControllerMain){
        [self.window setRootViewController:self.RootVC];
        NSString *hostItel=[[ItelAction action]getHost].itelNum;
        [[NSUserDefaults standardUserDefaults] setObject:hostItel forKey:@"currUser"];
        NSDictionary* params = @{
                                 kDomain:[info valueForKey:kDomain],
                                 kPort:[info valueForKey:kPort],
                                 kHostItelNumber:hostItel
                                 };
        [self setupIMManager:params];
//        [self.manager setup];
        [self.manager connectToSignalServer];
   }
    [UIView commitAnimations];
//    [self saveStoredCookies];
}

- (void) setupIMManager:(NSDictionary*) params{
    if ([[params allKeys] count] == 3) {
        [self.manager setRouteSeverIP:[params valueForKey:kDomain]];
        [self.manager setRouteServerPort:[[params valueForKey:kPort] intValue]];
        [self.manager setMyAccount:[params valueForKey:kHostItelNumber]];

    }
}
- (void)applicationWillResignActive:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillResignActive");
#endif
    if ([self.manager myState]&&![[[self.manager myState] valueForKey:kPeerAccount] isEqualToString:IDLE] && [self.manager myAccount]) {
        [self.manager haltSession:@{
                                    kType:[NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
                                    kSrcAccount:[self.manager myAccount],
                                    kDestAccount:[[self.manager myState] valueForKey:kPeerAccount] ,
                                    kHaltType:kEndSession
                                    
                                    }];

    }
//    [self.manager tearDown];
    [[ItelMessageInterfaceImp defaultMessageInterface] tearDown];
//    [self removeNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationDidEnterBackground");
#endif
    
    BOOL backgroundAccepted = [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        if ([[ItelAction action] getHost]) {
//            [self.manager setup];
            [self.manager connectToSignalServer];
        }
    
    }];
    if (backgroundAccepted)
    {
        NSLog(@"VOIP backgrounding accepted");
    }
//    [self.manager tearDown];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillEnterForeground ");
#endif
    [[UIApplication sharedApplication] clearKeepAliveTimeout];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationDidBecomeActive ");
#endif
    
    if ([[ItelAction action] getHost]) {
//        [self.manager setup];
//        [self.manager connectToSignalServer];
    }
//    [self registerNotifications];
    [[ItelMessageInterfaceImp defaultMessageInterface] setup];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#if APP_DELEGATE_DEBUG
    NSLog(@"调用 applicationWillTerminate");
#endif
    [self.manager logoutFromSignalServer];
    [self.manager tearDown];
    [[ItelMessageInterfaceImp defaultMessageInterface] tearDown];
    [self removeNotifications];
}

@end
