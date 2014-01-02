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
    [self.txtBirthday becomeFirstResponder];
   
    
}
-(void)sexSelect:(UIButton*)sender{
    //[self.window setHidden:YES];
    //self.window=nil;
}
-(void)finishButtonClicked{
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *birthday=[formatter stringForObjectValue:self.picker.date];
    [[ItelAction action ] modifyPersonal:@"birthday" forValue:birthday];
   
    [self.txtBirthday resignFirstResponder];
    
}
-(void)setPro:(HostItelUser *)host{
    if (self.picker==nil) {
        UIDatePicker *picker=[[UIDatePicker alloc] init];
        picker.datePickerMode=UIDatePickerModeDate;
        
        self.picker=picker;
        picker.backgroundColor=[UIColor whiteColor];
        
        UIButton *finish=[UIButton buttonWithType:UIButtonTypeSystem];
        float width=30;
        float height=20;
        finish.frame=CGRectMake(320-width-10, -20, width, height);
        [finish setTitle:@"完成" forState:UIControlStateNormal];
        [finish addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        self.txtBirthday.inputView=picker;
        self.txtBirthday.inputAccessoryView=finish;
    }
    self.txtBirthday.text=host.birthDay;
    
}
@end
