//
//  LoginViewModel.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//


#import "BaseViewModel.h"
@interface LoginViewModel : BaseViewModel
@property (nonatomic) NSString *itel;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *checkResult;
@property (nonatomic) NSArray *backUsers;
@property (nonatomic) NSNumber *showTableView; //bool 是否显示候选登陆table

@property (nonatomic) NSNumber *regType;   //bool 注册类型 1企业 0个人
-(void)login;
-(void)didSelectedUser:(NSDictionary*)user;
-(void)regSuccess:(NSNotification*)notify;
@end
