//
//  SecurityChangePasswordViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-21.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class regDetailTextField;

@interface SecurityChangePasswordViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet regDetailTextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet regDetailTextField *txtRepeatPassword;

@end
