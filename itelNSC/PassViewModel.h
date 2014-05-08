//
//  PassViewModel.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface PassViewModel : BaseViewModel
@property (nonatomic,strong) NSString *imgToken;
@property (nonatomic,strong) UIImage *codeImage;
@property (nonatomic,strong) NSString *itel;
@property (nonatomic,strong) NSString *code;
@property (nonatomic,strong) NSDictionary *securityData;
@property (nonatomic) NSNumber *startTimer; //bool 开始短信计时
@property (nonatomic) NSString *lastTime; //计时剩余时间
@property (nonatomic) NSTimer *timer; //短信重发计时器
@property (nonatomic) RACSignal *timerObserver; //监视定时器;
@property  (nonatomic) NSNumber *taskSuccess; //修改成功;
@property (nonatomic)  NSNumber *showModifyPassView; //弹出修改密码页面
@property (nonatomic) NSNumber *passwordCheckPassed; //密码检测通过
@property (nonatomic) NSString *theNewPassword;
@property (nonatomic) NSString *theNewRePassword;
@property (nonatomic) NSString *randomQuestion;
-(void)getToken;
-(void)getCodedImage;
-(void)checkSecurity;
-(void)sendMessage;
-(void)checkMesCode:(NSString*)code;
-(void)checkPassword;
-(void)sendNewPassword;
-(void)cgetRandomQuestion;
-(void)answerQuestion:(NSString*)answer;
-(void)sendEmail;
-(void)emailCodeCheck:(NSString*)code;
@end
