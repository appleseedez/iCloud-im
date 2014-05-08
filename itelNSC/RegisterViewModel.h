//
//  RegisterViewModel.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//


#import "BaseViewModel.h"
@interface RegisterViewModel : BaseViewModel
@property (nonatomic) NSString *itel;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *repassword;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *regError; //错误信息

@property (nonatomic) NSString *selectedItel; //随机选择的号码
@property (nonatomic) NSNumber *type;  //注册类型
@property (nonatomic) NSNumber *startTimer; //bool 开始短信计时
@property (nonatomic) NSString *lastTime; //计时剩余时间
@property (nonatomic) NSTimer *timer; //短信重发计时器
@property (nonatomic) RACSignal *timerObserver; //监视定时器;
@property (nonatomic) NSArray *randomNumbersDataSource;
-(BOOL)checkInput;
-(void)sendMessage;
-(void)checkItel;
-(void)checkMesCode:(NSString*)code;
-(void)getRandomNumbers;
@end
