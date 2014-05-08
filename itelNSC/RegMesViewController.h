//
//  RegMesViewController.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-5.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RegisterViewModel;
@class LoginViewModel;
@interface RegMesViewController : UIViewController
@property (nonatomic) RegisterViewModel *regViewModel;
@property (nonatomic) LoginViewModel *loginViewMode;
@end
