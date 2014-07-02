//
//  AppService.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "AppService.h"
#import "MaoAppDelegate.h"
#import "RoolViewController.h"
#import "LoginViewController.h"
#import "HTTPRequestBuilder+app.h"
#import <QuartzCore/QuartzCore.h>
#import "IMService.h"
@interface AppService ()

@property (nonatomic,weak) MaoAppDelegate *delegate;
@end
@implementation AppService
static AppService *instance;
+(instancetype)defaultService{
    return instance;
}
+ (void)initialize
{
    if (self == [AppService class]) {
        static BOOL initialized=NO;
        if (initialized==NO) {
            instance=[[[self class] alloc]init];
            initialized=YES;
        }
    }
}
-(void)logout{
    self.busy=@(YES);
        NSDictionary *parameters=@{@"itel":[self hostItel],@"onlymark":self.delegate.UUID};
         [[self.requestBuilder logout:parameters] subscribeNext:^(NSDictionary *x) {
             int code=[x[@"code"]intValue];
             if (code==200) {
                 
                 NSLog(@"正常登出");
                 self.delegate.loginInfo=nil;
                 self.rootViewType=@(rootViewTypeLogin);
             }else{
                 NSLog(@"异常登出");
                 self.delegate.loginInfo=nil;
                 self.rootViewType=@(rootViewTypeLogin);
             }
         }error:^(NSError *error) {
             NSLog(@"异常登出");
         }completed:^{
             self.busy=@(NO);
         }];
}
-(void)dropped:(NSNotification*)notify{
    self.rootViewType=@(rootViewTypeLogin);
    [[[UIAlertView alloc]initWithTitle:@"被踢下线" message:@"您的账号在另一台手机登陆，如非本人操作请检查账号安全" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
        self.rootViewType=@(rootViewTypeMain);
        __weak id weekSelf=self;
        [RACObserve(self, rootViewType) subscribeNext:^(NSNumber *x) {
          __strong  AppService *strongSelf=weekSelf;
            
            if ([x integerValue]==rootViewTypeLogin) {
                if (![strongSelf.delegate.window.rootViewController isKindOfClass:[LoginViewController class]]) {
                    CATransition *transition=[CATransition animation];
                    transition.type=@"push";
                    transition.subtype=@"fromLeft";
                    transition.duration=0.5;
                    strongSelf.delegate.window.rootViewController=nil;
                    [strongSelf.delegate.window setRootViewController:[strongSelf getLoginViewController]];
                    [strongSelf.delegate.window.layer addAnimation:transition forKey:@"1"];
                    [[IMService defaultService] tearDown];

                }
            }else {
                if (![strongSelf.delegate.window.rootViewController isKindOfClass:[RoolViewController class]]) {
                    CATransition *transition=[CATransition animation];
                    transition.type=@"push";
                    transition.subtype=@"fromRight";
                    transition.duration=0.5;
                     strongSelf.delegate.window.rootViewController=nil;
                [strongSelf.delegate.window setRootViewController:[strongSelf getMainViewController]];
                    [strongSelf.delegate.window.layer addAnimation:transition forKey:@"2"];
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[IMService defaultService] setup];
                    [[IMService defaultService] connectToSignalServer];
                     });
                }
            }
        }];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dropped:) name:@"dropped" object:nil];
    }
    return self;
}
-(UIViewController*)getMainViewController{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Root" bundle:nil];
    return [story instantiateInitialViewController];
}
-(UIViewController*)getLoginViewController{
    UIStoryboard *story=[UIStoryboard storyboardWithName:@"login" bundle:nil];
    return [story instantiateInitialViewController];
}
-(void)setHostWithKey:(NSString*)key value:(NSString*)value{
    NSMutableDictionary *dic=[self.delegate.loginInfo mutableCopy];
    [dic setObject:value forKey:key];
    self.delegate.loginInfo=[dic copy];
}
-(void)subDeviceToken:(NSString*)deviceToken{
    NSDictionary *parameters=@{@"itel":[self.delegate.loginInfo objectForKey:@"itel"],@"ios_token":deviceToken,@"type":@"phone-ios"};
    [[self.requestBuilder subPushToken:parameters]subscribeNext:^(id x) {
        
    }];
}
@end
