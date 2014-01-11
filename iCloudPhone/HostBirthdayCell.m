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
-(UIView*)inputAssesoryView{
    if (_inputAssesoryView==nil) {
        _inputAssesoryView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
        _inputAssesoryView.backgroundColor=[UIColor whiteColor];
        UIButton *finish=[UIButton buttonWithType:UIButtonTypeSystem];
        float width=50;
        float height=30;
        finish.frame=CGRectMake(320-width-10, 0, width, height);
        [finish setTitle:@"完成" forState:UIControlStateNormal];
        [finish addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIButton *cancel=[UIButton buttonWithType:UIButtonTypeSystem];
        cancel.frame=CGRectMake(10, 0, width, height);
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        [cancel addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_inputAssesoryView addSubview:finish];
        [_inputAssesoryView addSubview:cancel];
    }
    return _inputAssesoryView;
}
-(void)cancelButtonClicked{
    [self.txtBirthday resignFirstResponder];
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
        
        
        
        self.txtBirthday.inputView=picker;
        self.txtBirthday.inputAccessoryView=self.inputAssesoryView;
    }
    self.txtBirthday.text=host.birthday;
    
}
@end
