//
//  RootViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-18.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "RootViewController.h"
#import "CustomTabbar.h"
#import "CustonTarbarItem.h"
#import "IMCallingViewController.h"
#import "IMAnsweringViewController.h"
@interface RootViewController ()
@property (nonatomic,strong) CustomTabbar *customTabbar;
@end

@implementation RootViewController
-(void)setCustomTabbarHidden:(NSNotification*)notification{
    BOOL hidden=[[notification.userInfo objectForKey:@"hidden"] boolValue];
     [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionShowHideTransitionViews animations:^{
         self.customTabbar.alpha=!hidden;
         
     } completion:^(BOOL finished) {
         
     }];
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
#if ROOT_TABBAR_DEBUG
    NSLog(@"tabbar 加载了");
    NSAssert(self.manager, @"注入manager到tabroot失败");
#endif
    float height=[UIApplication sharedApplication].delegate.window.bounds.size.height;
    self.customTabbar  =[[CustomTabbar alloc]initWithFrame:CGRectMake(0, height-50, 320, 50)];
    [self.view addSubview:self.customTabbar];
    for (CustonTarbarItem *item in self.customTabbar.items) {
        [item addTarget:self action:@selector(changeController:) forControlEvents:UIControlEventTouchDown];
    }
    [self changeController:[self.customTabbar.items objectAtIndex:2] presentDialingView:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self registerNotifications];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
//    [self removeNotifications];
}
-(void)changeController:(CustonTarbarItem*)sender {
   
    [self changeController:sender presentDialingView:YES];
}
-(void)changeController:(CustonTarbarItem*)sender presentDialingView:(BOOL)presentDialingView{
    for (CustonTarbarItem *item in self.customTabbar.items ) {
        [item isSelected:NO];
    }
     [sender isSelected:YES];
    int i= [self.customTabbar.items indexOfObject:sender];
    if (i==0&&presentDialingView==YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"presentDialView" object:nil];
    }
    [self setSelectedIndex:i];
}
-(void)changeSubViewAtIndex:(NSInteger)index{
    BOOL present;
    //通话记录传10 其他传index
    if (index==10) {
        present=YES;
        index=0;
    }
    else present=NO;
    [self changeController:[self.customTabbar.items objectAtIndex:index] presentDialingView:present];
}
#pragma mark - PRIVATE
- (void) registerNotifications{
    // 当manager要求加载“拨打中”界面时，收到该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCallingView:) name:PRESENT_CALLING_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAnsweringView:) name:SESSION_PERIOD_REQ_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCustomTabbarHidden:) name:@"hideTab" object:nil];
}
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HANDLER
- (void) presentCallingView:(NSNotification*) notify{
//#if ROOT_TABBAR_DEBUG
//    NSLog(@"收到通知，将要加载CallingView");
//#endif
//    //加载“拨号中”界面
//    //加载stroyboard
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
//    UINavigationController* callingViewNavController = [sb instantiateViewControllerWithIdentifier:CALLING_VIEW_CONTROLLER_ID];
//    IMCallingViewController* callingViewController = (IMCallingViewController*) callingViewNavController.topViewController;
//    //    IMCallingViewController* callingViewController = [sb instantiateViewControllerWithIdentifier:CALLING_VIEW_CONTROLLER_ID];
//    callingViewController.manager = self.manager;
//    callingViewController.callingNotify = notify;
//    [self presentViewController:callingViewNavController animated:YES completion:nil];
#if ROOT_TABBAR_DEBUG
    NSLog(@"收到通知，将要加载CallingView");
#endif
    //加载“拨号中”界面
    //加载stroyboard
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    UINavigationController* callingViewNavController = [sb instantiateViewControllerWithIdentifier:CALLING_VIEW_CONTROLLER_ID];
    IMCallingViewController* callingViewController = (IMCallingViewController*) callingViewNavController.topViewController;
    callingViewController.manager = self.manager;
    callingViewController.callingNotify = notify;
    //获取到当前的顶层viewContorller
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:callingViewNavController animated:YES completion:nil];
    }else{
        [self presentViewController:callingViewNavController animated:YES completion:nil];
    }
   
}
- (void) presentAnsweringView:(NSNotification*) notify{
//#if ROOT_TABBAR_DEBUG
//    NSLog(@"收到通知，将要加载AnsweringView");
//#endif
//    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
//    UINavigationController* answeringViewNavController =[sb instantiateViewControllerWithIdentifier:ANSWERING_VIEW_CONTROLLER_ID];
//    IMAnsweringViewController* answeringViewController = (IMAnsweringViewController*) answeringViewNavController.topViewController;
//    //    IMAnsweringViewController* answeringViewController = [sb instantiateViewControllerWithIdentifier:ANSWERING_VIEW_CONTROLLER_ID];
//    answeringViewController.manager = self.manager;
//    answeringViewController.callingNotify = notify;
//    [self presentViewController:answeringViewNavController animated:YES completion:nil];
#if ROOT_TABBAR_DEBUG
    NSLog(@"收到通知，将要加载AnsweringView");
#endif
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    UINavigationController* answeringViewNavController =[sb instantiateViewControllerWithIdentifier:ANSWERING_VIEW_CONTROLLER_ID];
    IMAnsweringViewController* answeringViewController = (IMAnsweringViewController*) answeringViewNavController.topViewController;
    answeringViewController.manager = self.manager;
    answeringViewController.callingNotify = notify;
    //获取到当前的顶层viewContorller
    if (self.presentedViewController) {
        [self.presentedViewController presentViewController:answeringViewNavController animated:YES completion:nil];
    }else{
        [self presentViewController:answeringViewNavController animated:YES completion:nil];
    }
    
}

@end
