//
//  LoginViewController.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewModel;
@interface LoginViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) LoginViewModel *viewModel;
@end
