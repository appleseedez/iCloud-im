//
//  HostBirthdayCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostBirthdayCell.h"
#import "ItelAction.h"
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
    picker.center=CGPointMake(160, window.bounds.size.height-picker.bounds.size.height/2);
    self.picker=picker;
    picker.backgroundColor=[UIColor whiteColor];
    [window addSubview:picker];
    UIButton *finish=[UIButton buttonWithType:UIButtonTypeSystem];
    float width=30;
    float height=20;
    finish.frame=CGRectMake(320-width-10, window.bounds.size.height-picker.bounds.size.height, width, height);
    [finish setTitle:@"完成" forState:UIControlStateNormal];
    [finish addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [window addSubview:finish];
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:(UIViewAnimationOptionShowHideTransitionViews) animations:^{
        [window setHidden:NO];
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)sexSelect:(UIButton*)sender{
    //[self.window setHidden:YES];
    //self.window=nil;
}
-(void)finishButtonClicked{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *birthday=[formatter stringForObjectValue:self.picker.date];
    [[ItelAction action ] modifyPersonal:@"birthday" forValue:birthday];
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:(UIViewAnimationOptionShowHideTransitionViews) animations:^{
        [self.window setHidden:YES];
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)setPro:(HostItelUser *)host{
    self.birthdayLable.text=host.birthDay;
    
}
@end
