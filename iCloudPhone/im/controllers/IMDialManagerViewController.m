//
//  IMDialPanelViewController.m
//  iCloudPhone
//
//  Created by Pharaoh on 2/21/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "IMDialManagerViewController.h"
#import "IMDailViewController.h"
#import "IMCallingViewController.h"
#import "IMAnsweringViewController.h"
#import "NSCAppDelegate.h"
#import "IMDailViewController.h"
#import "IMCallingViewController.h"
#import "IMAnsweringViewController.h"
@implementation IMDialManagerViewController
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerNotifications];
    }
    return self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
   [self setup];
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}
- (void) setup{
}
- (void) registerNotifications{
    // 当manager要求加载“拨打中”界面时，收到该通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentCallingView:) name:PRESENT_CALLING_VIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentAnsweringView:) name:SESSION_PERIOD_REQ_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentDialPanelView:) name:PRESENT_DIAL_VIEW_NOTIFICATION object:Nil];
}
#pragma mark - HANDLER
- (void) presentDialPanelView:(NSNotification*) notify{
    IMDailViewController* dialViewController = (IMDailViewController*) [self.storyboard instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
    dialViewController.manager = self.manager;
    
}

- (void) presentCallingView:(NSNotification*) notify{
#if ROOT_TABBAR_DEBUG
    NSLog(@"收到通知，将要加载CallingView");
#endif
    //加载“拨号中”界面
    //加载stroyboard
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    UINavigationController* callingViewNavController = [sb instantiateViewControllerWithIdentifier:CALLING_VIEW_CONTROLLER_ID];
    IMCallingViewController* callingViewController = (IMCallingViewController*) callingViewNavController.topViewController;
    callingViewController.manager = self.manager;

}
- (void) presentAnsweringView:(NSNotification*) notify{
    
#if ROOT_TABBAR_DEBUG
    NSLog(@"收到通知，将要加载AnsweringView");
#endif
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    UINavigationController* answeringViewNavController =[sb instantiateViewControllerWithIdentifier:ANSWERING_VIEW_CONTROLLER_ID];
    IMAnsweringViewController* answeringViewController = (IMAnsweringViewController*) answeringViewNavController.topViewController;
    answeringViewController.manager = self.manager;
    answeringViewController.callingNotify = notify;

    
}
@end
