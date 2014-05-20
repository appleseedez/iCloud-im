//
//  MorePhoneViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-20.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MorePhoneViewModel.h"
#import "HTTPRequestBuilder+More.h"
#import "NXInputChecker.h"
@implementation MorePhoneViewModel
-(void)checkPhoneNumber:(NSString*)number{
    self.editingNewPhone=number;
    if (![NXInputChecker checkPhoneNumberIsMobile:number]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"输入手机格式不正确" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    self.busy=@(YES);
     NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"itelCode":[self hostItel],@"phone":number,};
    [[self.requestBuilder checkPhoneNumber:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
        }else {
            int code=[[x objectForKey:@"code"]intValue];
            if (code==200) {
                self.checkPassed=@(YES);
                
                
                
            }else{
                [self netRequestFail:x];
            }
            
        }
        
        
    } error:^(NSError *error) {
        self.busy=@(NO);
        [self netRequestError:error];
    } completed:^{
        self.busy=@(NO);
    }];
}
-(void)sendMessage{
    self.busy=@(YES);
    if (self.timerObserver==nil) {
        __weak id weakSelf=self;
        self.timerObserver= RACObserve(self, startTimer);
        [self.timerObserver  subscribeNext:^(NSNumber *x) {
            __strong   MorePhoneViewModel *strongSelf=weakSelf;
            if ([x boolValue]) {
                [strongSelf beginTimer];
            }else{
                [strongSelf.timer invalidate];
                
            }
        }];
        
    }
    NSDictionary *parameters=@{@"itelCode": [self hostItel],@"phone":self.editingNewPhone,@"userId":[self hostUserID]};
    
    [[self.requestBuilder moreSendMessager:parameters] subscribeNext:^(NSDictionary *x) {
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
    NSDictionary *parameters=@{@"userId":[self hostUserID] ,@"itelCode":[self hostItel],@"captcha":code,@"phone":self.editingNewPhone};
    [[self.requestBuilder checkCodeNumber:parameters] subscribeNext:^(NSDictionary *x) {
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            self.taskSuccess=@(YES);
            self.taskSuccess=@(NO);
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
    NSLog(@"MorePhoneModel被成功销毁");
}
@end
