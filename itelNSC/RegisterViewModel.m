//
//  RegisterViewModel.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RegisterViewModel.h"
#import "NXInputChecker.h"
#import "NSString+MD5.h"
#import "HTTPRequestBuilder+LoginAndRegister.h"
@implementation RegisterViewModel
-(BOOL)checkInput{
    if (![NXInputChecker checkEmpty:self.itel]) {
         self.regError=@"云号码不能为空";
        return NO;
    }
    
    if (![NXInputChecker checkEmpty:self.password]) {
        self.regError=@"密码不能为空";
        return NO;
    }
    if (![NXInputChecker checkEmpty:self.phone]) {
        self.regError=@"手机号码不能为空";
        return NO;
    }
    if (![NXInputChecker checkCloudNumber:self.itel]) {
        self.regError=@"云号码格式不正确";
        return NO;
    }
    if (![NXInputChecker checkPassword:self.password]) {
        self.regError=@"密码格式不正确，请输入长度大于6位小于20位的密码";
        return NO;
    }
    
    if (![self.password isEqualToString:self.repassword]) {
        self.regError=@"两次输入密码不一致";
        return NO;
    }
    
    
    if (![NXInputChecker checkPhoneNumberIsMobile:self.phone]) {
        self.regError= @"手机号码格式不正确";
        return NO;
    }

    return YES;
}
-(void)checkItel{
    self.busy=@(YES);
    if (self.timerObserver==nil) {
        __weak id weakSelf=self;
        self.timerObserver= RACObserve(self, startTimer);
        
        [self.timerObserver  subscribeNext:^(NSNumber *x) {
          __strong  RegisterViewModel *strongSelf=weakSelf;
            if ([x boolValue]) {
                [strongSelf beginTimer];
            }else{
                [strongSelf.timer invalidate];
                
            }
        }];

    }
    
    NSDictionary *parameters=@{@"itelCode": self.itel,@"type":self.type,@"phone":self.phone,@"password":self.password};
    
    RACSignal *checkItel=[self.requestBuilder regCheckItel:parameters];
    RACSubject *sendMessage=[RACSubject subject];
        [checkItel subscribeNext:^(NSDictionary *x) {
            if (![x isKindOfClass:[NSDictionary class]]) {
                [self serverError];
                return ;
            }
            int code=[[x objectForKey:@"code"]intValue];
            if (code==200) {
                [sendMessage sendCompleted];
            }else{
                [sendMessage sendError:nil];
                [[[UIAlertView alloc] initWithTitle:[x objectForKey:@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            }
        }completed:^{
            self.busy=@(NO);
        }];
      [checkItel subscribeError:^(NSError *error) {
          [sendMessage sendError:nil];
          [self netRequestError:error];
          self.busy=@(NO);
      }];
        
      [sendMessage subscribeCompleted:^{
          UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"手机短信验证" message:@"系统将发送一条短信验证您的手机 点击取消将不发送" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
          [alert show];
          [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
              if ([x intValue]==1) {
                  
                  [self sendMessage];
              }else{
                  return ;
              }
          }];
          
      }];
}
static int last =60;
-(void)beginTimer{
    last=60;
    self.timer =  [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRefresh:) userInfo:@(last) repeats:YES];
    
    [self.timer fire];
    
}
-(void)timeRefresh:(NSNumber*)lastTime{
    
    last--;
    if (last<=0) {
       
        
        
        self.startTimer=@(NO);
        self.lastTime=[NSString stringWithFormat:@"%d",last];
       
        
    }
    self.lastTime=[NSString stringWithFormat:@"%d",last];
   
}
-(void)sendMessage{
            NSDictionary *parameters=@{@"itelCode": self.itel ,@"phone":self.phone};
    self.busy=@(YES);
    RACSignal *sendMessage=[self.requestBuilder regSendMessage:parameters];
       [sendMessage subscribeNext:^(id x) {
           if (![x isKindOfClass:[NSDictionary class]]) {
               [self serverError];
               return ;
           }
           int code=[[x objectForKey:@"code"]intValue];
           if (code==200) {
               self.startTimer=@(YES);
           }else{
               [self netRequestFail:x];
           }
           NSLog(@"%@",[x objectForKey:@"msg"]);
       }error:^(NSError *error) {
           self.busy=@(NO);
       } completed:^{
           self.busy=@(NO);
       }];
    
}
-(void)checkMesCode:(NSString*)code{
    self.busy=@(YES);
           NSDictionary *parameters=@{@"itelCode": self.itel,@"type":self.type,@"phone":self.phone,@"password":[self.password MD5],@"captcha":code};
    RACSignal *checkMesCode=[self.requestBuilder regCheckMesCode:parameters];
           [checkMesCode subscribeNext:^(NSDictionary *x) {
               if (![x isKindOfClass:[NSDictionary class]]) {
                   [self serverError];
                   return ;
               }
               int code=[[x objectForKey:@"code"] intValue];
              
               
               if (code==200) {
                   //自动登陆
                   NSString *message=[NSString stringWithFormat:@"iTel号码 %@ 已经被您注册，请牢记您的iTel号码，以免丢失",self.itel];
                   UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜,注册成功" message:message delegate:self cancelButtonTitle:@"返回登陆" otherButtonTitles: nil];
                   [alert show];
                   [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"registeSuccess" object:self.itel userInfo:nil];
                   }];
                   
               }
               else {
                   UIAlertView *alert=[[UIAlertView alloc] initWithTitle:[x objectForKey:@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                   [alert show];
               }

           }completed:^{
               self.busy=@(NO);
           }];
     [checkMesCode subscribeError:^(NSError *error) {
         self.busy=@(YES);
         [self netRequestError:error];
     }];
}
-(void)getRandomNumbers{
    self.busy=@(YES);
      RACSignal *getNumbers=  [self.requestBuilder regGetRandomNumbers];
             [getNumbers subscribeNext:^(NSDictionary *x) {
                 if (![x isKindOfClass:[NSDictionary class]]) {
                     [self serverError];
                     return ;
                 }
                 int code=[[x objectForKey:@"code"] intValue];
                 if (code==200) {
                     self.randomNumbersDataSource=[x objectForKey:@"data"];
                 }else{
                     [self netRequestFail:x];
                 }
                 
                 
             } error:^(NSError *error) {
                 self.busy=@(NO);
                 [self netRequestError:error];
             } completed:^{
                 self.busy=@(NO);
             }];
    
}
-(void)dealloc{
    NSLog(@"registerViewModel 被销毁");
}
@end
