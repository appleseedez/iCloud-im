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
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
        self.rootViewType=@(rootViewTypeMain);
        
        [RACObserve(self, rootViewType) subscribeNext:^(NSNumber *x) {
            if ([x integerValue]==rootViewTypeLogin) {
                if (![self.delegate.window.rootViewController isKindOfClass:[LoginViewController class]]) {
                    CATransition *transition=[CATransition animation];
                    transition.type=@"push";
                    transition.subtype=@"fromLeft";
                    transition.duration=0.5;
                 
                [self.delegate.window setRootViewController:[self getLoginViewController]];
                    [self.delegate.window.layer addAnimation:transition forKey:@"1"];
                    
                }
            }else {
                if (![self.delegate.window.rootViewController isKindOfClass:[RoolViewController class]]) {
                    CATransition *transition=[CATransition animation];
                    transition.type=@"push";
                    transition.subtype=@"fromRight";
                    transition.duration=0.5;
                [self.delegate.window setRootViewController:[self getMainViewController]];
                    [self.delegate.window.layer addAnimation:transition forKey:@"2"];
                }
            }
        }];
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
@end
