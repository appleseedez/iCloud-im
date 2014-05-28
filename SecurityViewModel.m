//
//  SecurityViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-22.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "SecurityViewModel.h"
#import "HTTPRequestBuilder+More.h"
@implementation SecurityViewModel
-(void)getSecurity{
    self.busy=@(YES);
     NSDictionary *parameters = @{@"userId":[self hostUserID] };
      [[self.requestBuilder getUserSecurity:parameters] subscribeNext:^(NSDictionary *x) {
          if (![x isKindOfClass:[NSDictionary class]]) {
              [self responseError:x];
              return ;
          }
          int code=[[x objectForKey:@"code"]intValue];
          if (code==200) {
              //有密保
              self.questionData=[x objectForKey:@"data"];
          }else if (code==222){
              //无密保
              self.questionData=@{};
              
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
-(void)checkAnswer:(NSString*)question answer:(NSString*)answer{
    self.busy=@(YES);
     NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"question":question,@"answer":answer};
    [[self.requestBuilder checkUserAnswer:parameters]subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[[x objectForKey:@"code"] intValue];
        if (code==200){
            self.answerPassed=@(YES);
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
-(void)modifyProtection:(NSDictionary*)parameters{
    self.busy=@(YES);
    parameters =[parameters mutableCopy];
    [parameters setValue:[self hostUserID] forKey:@"userId"];
    [[self.requestBuilder modifyProtection:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[[x objectForKey:@"code"] intValue];
        if (code==200) {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"恭喜设置密保成功" message:@"请牢记您的密保" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [[[alert rac_buttonClickedSignal] map:^id(id value) {
                self.modifySuccess=@(YES);
                return value;
            }] subscribeNext:^(id x) {
                
            }];
            [alert show];
            
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
- (void)dealloc
{
    NSLog(@"securityViewModel 被销毁");
}
@end
