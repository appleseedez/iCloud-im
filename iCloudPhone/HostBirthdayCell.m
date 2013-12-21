//
//  HostBirthdayCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostBirthdayCell.h"

@implementation HostBirthdayCell

-(void)showSettingView:(UIViewController *)viewController{
    UIWindow *window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window=window;
    [window setWindowLevel:UIWindowLevelStatusBar];
    window.backgroundColor=[UIColor clearColor];
    window.alpha=1;
    UIButton *back=[[UIButton alloc]initWithFrame:window.bounds];
    back.backgroundColor=[UIColor grayColor];
    back.alpha=0.5;
    back.tag=25467;
    [back  addTarget:self action:@selector(sexSelect:) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:back];
    UIDatePicker *picker=[[UIDatePicker alloc] init];
    picker.datePickerMode=UIDatePickerModeDate;
    picker.center=CGPointMake(160, window.bounds.size.height-picker.bounds.size.height);
    picker.backgroundColor=[UIColor whiteColor];
    [window addSubview:picker];
    [window setHidden:NO];
}
-(void)sexSelect:(UIButton*)sender{
    [self.window setHidden:YES];
    self.window=nil;
}
@end
