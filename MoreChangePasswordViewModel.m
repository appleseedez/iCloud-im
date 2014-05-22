//
//  MoreChangePasswordViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreChangePasswordViewModel.h"
#import "HTTPRequestBuilder+More.h"
@implementation MoreChangePasswordViewModel
-(void)changePassword:(NSString*)newPassword oldPassword:(NSString*)oldPassword{
    self.busy=@(YES);
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"oldPassword":oldPassword,@"newPassword":newPassword,};
       
    [[self.requestBuilder changePassword:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code = [[x objectForKey:@"code"]intValue];
        if (code==200) {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"恭喜修改密码成功" message:@"请牢记您的新密码" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            __weak id weaSelf=self;
            [alert show];
            [[alert rac_buttonClickedSignal] subscribeNext:^(id x) {
              __strong  MoreChangePasswordViewModel *strongSelf=weaSelf;
                strongSelf.passwordChanged=@(YES);
            }];
            
            
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
    NSLog(@"changePasswordViewModel被销毁");
}
@end
