//
//  SecurityChangePasswordViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MoreChangePasswordViewModel;
@interface SecurityChangePasswordViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtRepeatPassword;
@property (nonatomic)   MoreChangePasswordViewModel *changePasswordViewModel;
@end
