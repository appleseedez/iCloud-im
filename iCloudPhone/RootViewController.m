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
#import "NewMessageView.h"
#import "ItelAction.h"
#import "IMDailViewController.h"
#import "115MainViewController.h"
@interface RootViewController ()
@property (nonatomic,strong) CustomTabbar *customTabbar;
@property (nonatomic,strong) NewMessageView *newMessage;
@end

@implementation RootViewController
-(NewMessageView*)newMessage{
    if (_newMessage==nil) {
        _newMessage=[[NewMessageView alloc]initWithFrame:CGRectMake(40, 2.5, 10, 10)];
    }
    return _newMessage;
}
-(void)setCustomTabbarHidden:(NSNotification*)notification{
    BOOL hidden=[[notification.userInfo objectForKey:@"hidden"] boolValue];
     [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionAllowUserInteraction animations:^{
         self.customTabbar.alpha=!hidden;
         
     } completion:^(BOOL finished) {
         
     }];
    
}

//
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tabBar setHidden:YES];
    self.hidesBottomBarWhenPushed=YES;
    [self.tabBar removeFromSuperview];
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
    [self changeMain];
}
-(void)changeMain{
    [self changeController:[self.customTabbar.items objectAtIndex:2] presentDialingView:NO];
    [self setSelectedIndex:2];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerNotifications];
    [self.view bringSubviewToFront:self.customTabbar];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"rootViewAppear" object:nil];
}
static int count = 0;
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"rootviewcontroller %d",++count);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"rootViewDisappear" object:nil];
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
//        [self presentDialingViewController];
//        [self.manager presentDialRelatedPanel];
        [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_DIAL_VIEW_NOTIFICATION object:nil];
    }
    [self setSelectedIndex:i];
}
-(void)presentDialingViewController{
    
    IMDailViewController* dialViewController = (IMDailViewController*) [self.storyboard instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
    dialViewController.manager = self.manager;
    [self presentViewController:dialViewController animated:YES completion:nil];
}
-(void)changeSubViewAtIndex:(NSInteger)index{
    BOOL present;
    //通话记录传10 其他传index
    if (index==10) {
        present=NO;
        index=0;
    }
    else present=YES;
    [self changeController:[self.customTabbar.items objectAtIndex:index] presentDialingView:present];
}
#pragma mark - PRIVATE
- (void) registerNotifications{
//    // 当manager要求加载“拨打中”界面时，收到该通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCallingView:) name:PRESENT_CALLING_VIEW_NOTIFICATION object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAnsweringView:) name:SESSION_PERIOD_REQ_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setCustomTabbarHidden:) name:@"hideTab" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewMessage:) name:@"searchForNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNewMessage:) name:@"checkNewMessage" object:nil];
}
-(void)showNewMessage:(NSNotification*)notification{
    BOOL isNormal=[[notification.userInfo objectForKey:@"isNormal"]boolValue];
    if (isNormal) {
        CustonTarbarItem *message=[self.customTabbar.items objectAtIndex:3];
        [message addSubview:self.newMessage];
    }
   
}
-(void)checkNewMessage:(NSNotification*)notification{
    [self.newMessage removeFromSuperview];
}
- (void) removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
