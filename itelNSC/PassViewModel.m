//
//  PassViewModel.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "PassViewModel.h"
#import "NXInputChecker.h"
#import "NSString+MD5.h"
#import "HTTPRequestBuilder+LoginAndRegister.h"
@implementation PassViewModel
-(void)getToken{
    self.busy=@(YES);
    RACSignal *getToken = [self.requestBuilder passGetToken];
    [getToken subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self serverError];
            return ;
        }
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.imgToken=[[x objectForKey:@"data"]objectForKey:@"token"];
        }
        
    }error:^(NSError *error) {
        self.busy=@(NO);
    }completed:^{
        self.busy=@(NO);
    }];
}
-(void)getCodedImage{
    self.busy=@(YES);
    [[self.requestBuilder passGetCodeImage:self.imgToken]subscribeNext:^(NSData *x) {
        self.codeImage=[UIImage imageWithData:x];
        
    }error:^(NSError *error) {
        self.busy=@(NO);
    }completed:^{
        self.busy=@(NO);
    }];
}
-(void)checkSecurity{
    NSDictionary *parameters=@{@"itel": self.itel,@"verifycode":self.code,@"token":self.imgToken};
    self.busy=@(YES);
    RACSignal *checkSecurity=[self.requestBuilder passCheckToken:parameters];
          [checkSecurity subscribeNext:^(NSDictionary *x) {
              if (![x isKindOfClass:[NSDictionary class]]) {
                  [self serverError];
                  return ;
              }
              int code=[[x objectForKey:@"code"]intValue];
              if (code==200) {
                  self.securityData=[x objectForKey:@"data"];
              }else{
                  [self netRequestFail:x];
              }
          }error:^(NSError *error) {
              self.busy=@(NO);
              [self netRequestError:error];
          }completed:^{
              self.busy=@(NO);
          }];
}
-(void)sendMessage{
    self.busy=@(YES);
    if (self.timerObserver==nil) {
        self.timerObserver= RACObserve(self, startTimer);
        [self.timerObserver  subscribeNext:^(NSNumber *x) {
            if ([x boolValue]) {
                [self beginTimer];
            }else{
                [self.timer invalidate];
                
            }
        }];
        
    }
    NSDictionary *parameters=@{@"itelCode": [self.securityData objectForKey:@"username"],@"phone":[self.securityData objectForKey:@"phone"]};
    
      [[self.requestBuilder passSendMessage:parameters] subscribeNext:^(NSDictionary *x) {
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
          
      }completed:^{
          self.busy=@(NO);
      }];
    
}
-(void)sendEmail{
    self.busy=@(YES);
    NSDictionary *parameters=@{@"itel":[self.securityData objectForKey:@"username"]};
     [[self.requestBuilder passSendEmail:parameters]subscribeNext:^(NSDictionary *x) {
         if (![x isKindOfClass:[NSDictionary class]]) {
             [self serverError];
             return ;
         }
         int code=[[x objectForKey:@"code"]intValue];
         if (code==200) {
             [[[UIAlertView alloc]initWithTitle:@"邮件已经发送，请查收" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
         }else{
             [self netRequestFail:x];
         }
     }error:^(NSError *error) {
         self.busy=@(NO);
         [self netRequestError:error];
     }completed:^{
         self.busy=@(NO);
     }];
}
-(void)emailCodeCheck:(NSString*)code{
    self.busy=@(YES);
    NSDictionary *parameters=@{@"itel":[self.securityData objectForKey:@"username"],@"code":code};
    [[self.requestBuilder passCheckEmailCode:parameters]subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self serverError];
            return ;
        }
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.showModifyPassView=@(YES);
            self.showModifyPassView=@(NO);
        }else{
            [self netRequestFail:x];
        }
    }error:^(NSError *error) {
        self.busy=@(NO);
        [self netRequestError:error];
    }completed:^{
        self.busy=@(NO);
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
-(void)checkMesCode:(NSString*)code{
    self.busy=@(YES);
    NSDictionary *parameters=@{@"userId":[self.securityData objectForKey:@"userId"] ,@"itelCode":[self.securityData objectForKey:@"username"],@"captcha":code,@"phone":[self.securityData objectForKey:@"phone"]};
    [[self.requestBuilder passCheckPhoneCode:parameters] subscribeNext:^(NSDictionary *x) {
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.showModifyPassView=@(YES);
            self.showModifyPassView=@(NO);
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

-(void)checkPassword{
    NSString *result=nil;
    if (![NXInputChecker checkEmpty:self.theNewPassword]) {
          result=@"密码输入不能为空";
        
    }
   else if (![NXInputChecker checkEmpty:self.theNewPassword]) {
        result=@"重复密码输入不能为空";
       
    }
   else if (![NXInputChecker checkPassword:self.theNewPassword]) {
          result=@"密码长度必须在6-20位之间";
       
    }
   else if (![self.theNewPassword isEqualToString:self.theNewRePassword]){
           result = @"两次输入密码不一致";
   }
    if (result==nil) {
        self.passwordCheckPassed=@(YES);
        self.passwordCheckPassed=@(NO);
    }else{
        [[[UIAlertView alloc]initWithTitle:result message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}
-(void)cgetRandomQuestion{
    int number=arc4random()%3;
    NSString *key=nil;
    switch (number) {
        case 0:
             key=@"question1";
            break;
        case 1:
            key=@"question2";
            break;
        case 2:
            key=@"question3";
            break;
        default:
            break;
    }
    self.randomQuestion=[self.securityData objectForKey:key];
    
}
-(void)answerQuestion:(NSString*)answer{
    self.busy=@(YES);
    NSDictionary *parameters=@{@"question": self.randomQuestion,
                               @"answer":answer,
                               @"userId":[self.securityData objectForKey:@"userId"]
                               };
    [[self.requestBuilder passAnswerQuestion:parameters] subscribeNext:^(NSDictionary *x) {
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.showModifyPassView=@(YES);
            self.showModifyPassView=@(NO);
        }else{
            [self netRequestFail:x];
        }
        
    }error:^(NSError *error) {
        self.busy=@(NO);
        [self netRequestError:error];
    }completed:^{
        self.busy=@(NO);
    }];
}
-(void)sendNewPassword{
    self.busy=@(YES);
    NSDictionary *parameters=@{@"itel":[self.securityData objectForKey:@"username"],@"password":[self.theNewPassword MD5]};
    
    [[self.requestBuilder passSendNewPassword:parameters] subscribeNext:^(NSDictionary *x) {
        int code =[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.taskSuccess=@(YES);
        }else{
            [self netRequestFail:x];
        }
        
        
    }error:^(NSError *error) {
        self.busy=@(NO);
        [self netRequestError:error];
    }completed:^{
        self.busy=@(NO);
    }];
}



















@end
