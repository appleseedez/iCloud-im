//
//  SecuretyAnswerQuestionViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-26.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SecurityViewModel;
@interface SecuretyAnswerQuestionViewController : UIViewController
@property (nonatomic,strong) NSDictionary *data;
@property (nonatomic,weak)   SecurityViewModel *securityViewModel;
@end
