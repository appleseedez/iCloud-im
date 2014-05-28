//
//  SecuretyQuestionViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-25.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SecurityViewModel;
@interface SecuretyQuestionViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic) SecurityViewModel *securityViewModel;

@end
