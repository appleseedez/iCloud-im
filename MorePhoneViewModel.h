//
//  MorePhoneViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-20.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface MorePhoneViewModel : BaseViewModel
@property (nonatomic) NSString *editingNewPhone;
-(void)checkPhoneNumber:(NSString*)number;
@property  (nonatomic) NSNumber *checkPassed;
@property (nonatomic) NSNumber *startTimer; //bool 开始短信计时
@property (nonatomic) NSString *lastTime; //计时剩余时间
@property (nonatomic) NSTimer *timer; //短信重发计时器
@property (nonatomic) RACSignal *timerObserver; //监视定时器;
@property  (nonatomic) NSNumber *taskSuccess; //修改成功;

-(void)sendMessage;
-(void)checkMesCode:(NSString*)code;
@end
