//
//  RegDetailViewController.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewModel;
@class RegisterViewModel;
@interface RegDetailViewController : UIViewController <UIScrollViewDelegate,UITextFieldDelegate>
@property (nonatomic) LoginViewModel *viewModel;
@property (nonatomic) RegisterViewModel *regViewModel;
@property (nonatomic) NSNumber *regType;
@end
