//
//  ReacabilityManager.m
//  itelNSC
//
//  Created by nsc on 14-6-25.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "ReacabilityManager.h"
#import <Reachability/Reachability.h>
@implementation ReacabilityManager
static ReacabilityManager *instance;
+(instancetype)defarutManager{
    return instance;
}
+ (void)initialize
{
    if (self == [ReacabilityManager class]) {
        static BOOL didInit=NO;
        if (!didInit) {
            instance=[[ReacabilityManager alloc]init];
            [instance getNetStatus];
        }
    }
}
-(void)getNetStatus{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    NSString *remoteHostName = @"www.baidu.com";
    Reachability *hostReachability = [Reachability reachabilityWithHostname:remoteHostName];
    [hostReachability startNotifier];
}



- (void) reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:        {
            // 无网络
            NSLog(@"无网络");
            self.currNetStatus=@(netStatusNonet);
            break;
        }
            
        case ReachableViaWWAN:        {
            // 移动网络
             NSLog(@"3G");
            self.currNetStatus=@(netStatus3G);
              
            break;
        }
        case ReachableViaWiFi:        {
            // wifi
            self.currNetStatus=@(netStatusWifi);

             NSLog(@"wifi");
            break;
        }
    }
    
}
@end
