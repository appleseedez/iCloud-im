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

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
