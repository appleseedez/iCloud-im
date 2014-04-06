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
#import "NXInputChecker.h"

#import "IMDailViewController.h"
#import "IMCallingViewController.h"
#import "IMAnsweringViewController.h"
#import "ItelUpdateManager.h"
#import "NetRequester.h"
#define winFrame [UIApplication sharedApplication].delegate.window.bounds

@interface ItelMessageInterfaceImp ()
+ (instancetype)defaultMessageInterface;
- (void)setup;
- (void)tearDown;
@end

@implementation NSCAppDelegate
- (void)signOut {
     
  [[ItelAction action] logout];
  [self.manager dismissDialRelatedPanel];
  [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"currUser"];

  [self.manager logoutFromSignalServer];
  [self changeRootViewController:RootViewControllerLogin userInfo:nil];
  [self.manager clearTable];
  [self.manager tearDown];
}

- (void)reconnect:(NSNotification *)notify {
  if (ConnectionFlagNoConnection == self.connectionFlag.integerValue) {
    return;
  }
  [self performSelector:@selector(connectAfterDelay)
             withObject:nil
             afterDelay:0.5];
}
- (void)connectAfterDelay {
  if ([[ItelAction action] getHost] && self.manager &&
      ![[self.manager myAccount] isEqualToString:BLANK_STRING]) {

    [self.manager connectToSignalServer];
  }
}
- (void)setupManagers {
}
#pragma mark - 被快鱼掉起来
- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation {

  NSDictionary *pass = [NXInputChecker parmetersInUrl:url];
  NSString *sessiontoken = [pass objectForKey:@"token"];
  if ([sessiontoken isEqual:[NSNull null]]) {

    [self returnAppCall:[pass objectForKey:@"typeUrl"]];
    return YES;
  }
  NSString *backURL = [pass objectForKey:@"typeUrl"];

  NSString *logUrl =
      [NSString stringWithFormat:@"%@/loginBySessiontoken.json", SIGNAL_SERVER];
  NSDictionary *parameters = @{
    @"type" : @"phone-ios",
    @"itel" : [pass objectForKey:@"itel"],
    @"sessiontoken" : sessiontoken
  };

  NSDictionary *loginDic =
      [NetRequester syncJsonPostRequestWithUrl:logUrl parameters:parameters];
  if (loginDic == nil) {
    [self returnAppCall:backURL];
    return YES;
  }

  id ret = [loginDic objectForKey:@"ret"];
  if (ret == nil || [ret intValue] != 0) {
    [self returnAppCall:backURL];
    return YES;
  }
  NSDictionary *dic = [[loginDic objectForKey:@"message"] objectForKey:@"data"];
  self.startExtra = @{ @"itelNumber" : [pass objectForKey:@"targetItel"] };
  if (dic) {

    HostItelUser *host = [[ItelAction action] getHost];

    if (host == nil) {
      host = [HostItelUser userWithDictionary:[dic mutableCopy]];
    }
    [host setPersonal:dic];
    host.token = [dic objectForKey:@"sessiontoken"];

    if ([self.window.rootViewController
            isKindOfClass:[NXLoginViewController class]]) {

      NSDictionary *tokens = [dic objectForKey:@"tokens"];
      if (tokens) {
        host.sessionId = [tokens objectForKey:@"jsessionid"];
        host.spring_security_remember_me_cookie =
            [tokens objectForKey:@"spring_security_remember_me_cookie"];
        host.token = [tokens objectForKey:@"token"];
      }

      [[ItelAction action] setHostItelUser:host];

      [[ItelAction action] resetContact];

      [self changeRootViewController:RootViewControllerMain userInfo:dic];

      [[ItelAction action] checkAddressBookMatchingItel];
      [[ItelAction action] getItelBlackList:0];
      [[ItelAction action] getItelFriendList:0];
    } else {
      if (![[[ItelAction action] getHost].itelNum
               isEqualToString:[dic objectForKey:@"itel"]]) {
        [self signOut];
        UIAlertView *alert = [[UIAlertView alloc]
                initWithTitle:@"自动登录失败"
                      message:@"当前启动用户与自动登录用户冲突 请重新登录"
                     delegate:nil
            cancelButtonTitle:@"确定"
            otherButtonTitles:nil];

        [alert performSelector:@selector(show) withObject:nil afterDelay:0.2];
        return YES;
      } else {
        [[ItelAction action] setHostItelUser:host];
      }
    }
    if (self.startExtra) {
      [self doExtra];
    }
  }

  return YES;
}
- (void)returnAppCall:(NSString *)url {

  if ([[UIApplication sharedApplication]
          canOpenURL:[NSURL URLWithString:url]]) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
  } else {
    [self signOut];
  }
}
- (void)doExtra {
  [[NSNotificationCenter defaultCenter]
      postNotificationName:PRESENT_DIAL_VIEW_NOTIFICATION
                    object:nil
                  userInfo:[self.startExtra copy]];
  self.startExtra = nil;
}

- (void)registerNotifications {

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(signOut)
                                               name:@"signOut"
                                             object:nil];

  //绑定重连通知

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(reconnect:)
             name:RECONNECT_TO_SIGNAL_SERVER_NOTIFICATION
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(presentCallingView:)
             name:PRESENT_CALLING_VIEW_NOTIFICATION
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(presentAnsweringView:)
             name:SESSION_PERIOD_REQ_NOTIFICATION
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(presentDialPanelView:)
             name:PRESENT_DIAL_VIEW_NOTIFICATION
           object:Nil];
}
- (void)removeNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

void *ConnectionFlagKVOContext = &ConnectionFlagKVOContext;
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self addObserver:self
         forKeyPath:@"connectionFlag"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:&ConnectionFlagKVOContext];
  if (self.phoneBook == nil) {
    self.phoneBook = [[AddressBook alloc] init];
    [self.phoneBook loadAddressBook];
  }

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
    while (self.UUID == nil) {
      self.UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
  });

  [[IMCoreDataManager defaulManager] isAreaInCoreData]; //地名插入coredata
  //初始化ItelMessageInterface
  RootViewController *rootVC =
      (RootViewController *)self.window.rootViewController;
  //实例化manager
  self.manager = [[IMManagerImp alloc] init];
  //[self.manager setup];
  [self registerNotifications];
  [[ItelMessageInterfaceImp defaultMessageInterface] setup];
  rootVC.manager = self.manager;

  self.dialPanelWindow =
      [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, APP_SCREEN.size.width,
                                                 APP_SCREEN.size.height)];
  self.dialPanelWindow.windowLevel = UIWindowLevelNormal;

  self.RootVC = rootVC;

  //===========================登陆注册=============================
  UIStoryboard *loginStoryboard =
      [UIStoryboard storyboardWithName:@"Login_iPhone" bundle:nil];

  NXLoginViewController *loginVC =
      [loginStoryboard instantiateViewControllerWithIdentifier:@"login"];
  self.loginVC = loginVC;

  [self checkAutoLogin];

  //   [[ItelBookManager defaultManager] phoneBook];

  if (self.autoLogin) {
    [self.window setRootViewController:rootVC];
  } else {
    [self.window setRootViewController:loginVC];
  }

  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)checkAutoLogin {
  //查询currUser
  HostItelUser *currUser = nil;
  NSString *hostItel =
      [[NSUserDefaults standardUserDefaults] objectForKey:@"currUser"];
  if (![hostItel isEqualToString:@"0"]) {
    IMCoreDataManager *manager = [IMCoreDataManager defaulManager];

    NSFetchRequest *getHost =
        [NSFetchRequest fetchRequestWithEntityName:@"HostItelUser"];
    getHost.sortDescriptors = @[];
    NSArray *host =
        [[manager managedObjectContext] executeFetchRequest:getHost error:nil];
    if (host) {
      for (HostItelUser *user in host) {
        if ([user.itelNum isEqualToString:hostItel]) {
          currUser = user;
        }
      }
    }
  }

  if (currUser == nil) {
    self.autoLogin = 0;
  } else { //自动登陆
    self.autoLogin = 1;
    [[ItelAction action] setHostItelUser:currUser];
    NSDictionary *params = @{
      kDomain : currUser.domain,
      kPort : currUser.port,
      kHostItelNumber : currUser.itelNum
    };
    [[ItelAction action] checkAddressBookMatchingItel];
    [self setupIMManager:params];
    if ([[ItelAction action] getHost]) {
      [self.manager setup];
      [self.manager connectToSignalServer];
    }
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (context == ConnectionFlagKVOContext) {
    // 只有在登录状态下面才有操作
    if ([[ItelAction action] getHost]) {
      NSInteger newValue = [[change objectForKey:@"new"] integerValue];
      if (newValue == ConnectionFlagNoConnection) {
        [TSMessage
            showNotificationInViewController:[UIApplication sharedApplication]
                                                 .keyWindow.rootViewController
                                       title:NSLocalizedString(@"网络异常!",
                                                               nil)
                                    subtitle:NSLocalizedString(
                                                 @"侦测到当前网络处于断开状态.",
                                                 nil)
                                       image:nil
                                        type:TSMessageNotificationTypeError
                                    duration:36000
                                    callback:
                                        ^{
                                          [TSMessage dismissActiveNotification];
                                        }
                                 buttonTitle:nil
                              buttonCallback:nil
                                  atPosition:TSMessageNotificationPositionBottom
                        canBeDismissedByUser:YES];
      } else if (newValue == ConnectionFlagPending) {

      } else if (newValue == ConnectionFlagConnected) {
      }
    }
  }
}

- (void)changeRootViewController:(setRootViewController)Type
                        userInfo:(NSDictionary *)info {
  CATransition *trans = [CATransition animation];
  trans.duration = 0.5;
  trans.type = @"oglFlip";
  if (Type == RootViewControllerLogin) {
    [self.window setRootViewController:self.loginVC];
    [self.manager tearDown];
    [self.manager disconnectToSignalServer];
    [self.manager setMyAccount:nil];
    trans.subtype = @"fromTop";
    //        [[NSNotificationCenter defaultCenter]
    // postNotificationName:@"rootViewDisappear" object:nil];
  } else if (Type == RootViewControllerMain) {
    [self.RootVC changeMain];
    [self.window setRootViewController:self.RootVC];
    NSString *hostItel = [[ItelAction action] getHost].itelNum;
    [[NSUserDefaults standardUserDefaults] setObject:hostItel
                                              forKey:@"currUser"];
    [self.manager setup];
    NSDictionary *params = @{
      kDomain : [info valueForKey:kDomain],
      kPort : [info valueForKey:kPort],
      kHostItelNumber : hostItel
    };
    [self setupIMManager:params];
    //        [self.manager setup];
    [self.manager connectToSignalServer];
    trans.subtype = @"fromBottom";
  }
  [self.window.layer addAnimation:trans forKey:nil];

  //    [self saveStoredCookies];
}

- (void)setupIMManager:(NSDictionary *)params {
  NSLog(@"setupIMMAnger:params:%@", params);
  if ([[params allKeys] count] == 3) {
    [self.manager setRouteSeverIP:[params valueForKey:kDomain]];
    [self.manager setRouteServerPort:[[params valueForKey:kPort] intValue]];
    [self.manager setMyAccount:[params valueForKey:kHostItelNumber]];
  }
}

- (void)applicationWillResignActive:(UIApplication *)application {
  self.ignoreOnce = NO;
#if APP_DELEGATE_DEBUG
  NSLog(@"调用 applicationWillResignActive");
#endif
  if ([self.manager myState] &&
      ![[[self.manager myState] valueForKey:kPeerAccount]
           isEqualToString:IDLE] &&
      [self.manager myAccount]) {
    [self.manager
        haltSession:
            @{
              kType : [NSNumber numberWithInteger:SESSION_PERIOD_HALT_TYPE],
              kSrcAccount : [self.manager myAccount],
              kDestAccount : [[self.manager myState] valueForKey:kPeerAccount],
              kHaltType : kEndSession
            }];
  }
  //    [self.manager tearDown];
  [[ItelMessageInterfaceImp defaultMessageInterface] tearDown];
  //    [self removeNotifications];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

#if APP_DELEGATE_DEBUG
  NSLog(@"调用 applicationDidEnterBackground");
#endif
  BOOL backgroundAccepted = [[UIApplication sharedApplication]
      setKeepAliveTimeout:NSTimeIntervalSince1970
                  handler:^{
                    if ([[ItelAction action] getHost]) {
                      //            [self.manager sendHeartbeat];
                    }
                  }];
  if (backgroundAccepted) {
    NSLog(@"VOIP backgrounding accepted");
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
    [[AVAudioSession sharedInstance]
        setCategory:AVAudioSessionCategoryPlayAndRecord
        withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
              error:&error];
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
#if APP_DELEGATE_DEBUG
  NSLog(@"调用 applicationWillEnterForeground ");

#endif

  [[UIApplication sharedApplication] clearKeepAliveTimeout];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {

  self.ignoreOnce = YES;
  [[ItelUpdateManager defaultManager] checkUpdate];

#if APP_DELEGATE_DEBUG
  NSLog(@"调用 applicationDidBecomeActive ");
#endif
  if ([[ItelAction action] getHost]) {
    //        [self.manager checkTCPAlive];
    [self.manager checkConnectionToServer];
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
#if APP_DELEGATE_DEBUG
  NSLog(@"调用 applicationWillTerminate");
#endif
  [self.manager logoutFromSignalServer];
  [self.manager tearDown];
  [[ItelMessageInterfaceImp defaultMessageInterface] tearDown];
  [self removeNotifications];
}
#pragma mark - HANDLER
- (void)presentDialPanelView:(NSNotification *)notify {
  UIStoryboard *sb =
      [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
  IMDailViewController *dialViewController = (IMDailViewController *)
      [sb instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
  dialViewController.manager = self.manager;

  if ([notify.userInfo valueForKey:@"itelNumber"]) {
    dialViewController.directNumber =
        [notify.userInfo valueForKey:@"itelNumber"];
  }
  [self.manager presentDialRelatedPanel:dialViewController];
}

- (void)presentCallingView:(NSNotification *)notify {
#if ROOT_TABBAR_DEBUG
  NSLog(@"收到通知，将要加载CallingView");
#endif
  //加载“拨号中”界面
  //加载stroyboard
  UIStoryboard *sb =
      [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
  IMCallingViewController *callingViewController = (IMCallingViewController *)
      [sb instantiateViewControllerWithIdentifier:CALLING_VIEW_CONTROLLER_ID];
  callingViewController.manager = self.manager;
  [self.manager presentDialRelatedPanel:callingViewController];
}
- (void)presentAnsweringView:(NSNotification *)notify {

#if ROOT_TABBAR_DEBUG
  NSLog(@"收到通知，将要加载AnsweringView");
#endif
  UIStoryboard *sb =
      [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
  IMAnsweringViewController *answeringViewController =
      (IMAnsweringViewController *)
      [sb instantiateViewControllerWithIdentifier:ANSWERING_VIEW_CONTROLLER_ID];
    answeringViewController.manager = self.manager;
    answeringViewController.callingNotify = notify;
    
    [self.manager presentDialRelatedPanel:answeringViewController];
    
    
}
@end
