//
//  LoginViewModel.m
//  RegisterAndLogin
//
//  Created by nsc on 14-5-4.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "LoginViewModel.h"
#import "NXInputChecker.h"
#import "HTTPRequestBuilder+LoginAndRegister.h"
@implementation LoginViewModel
-(NSString*)checkInput{
    if (![NXInputChecker checkEmpty:self.itel]) {
             return @"iTel号码不能为空";
    }
    if (![NXInputChecker checkEmpty:self.password]) {
           return @"密码不能为空";
    }
    
    
    
    
    return nil;
}

-(void)login{
    
    NSString *loginError=[self checkInput];
    if (loginError) {
        [[[UIAlertView alloc]initWithTitle:@"登陆失败" message:loginError delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        return;
    }
    
    self.busy=@(YES);
    RACSignal *loginSignal=[self.requestBuilder login:self.itel password:self.password];
      [loginSignal subscribeNext:^(NSDictionary *x) {
          if (![x isKindOfClass:[NSDictionary class]]) {
              [self serverError];
              return ;
          }
          NSDictionary *dic=[x objectForKey:@"message"];
          int code=[[dic objectForKey:@"code"] intValue];
          if (code==200) {
              [[NSNotificationCenter defaultCenter]postNotificationName:@"loginSuccess" object:nil userInfo: [dic objectForKey:@"data"]];
              
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *arr=[self.backUsers mutableCopy];
                for (NSDictionary *x in self.backUsers) {
                    NSString *usercode=[x objectForKey:@"itel"];
                    if ([usercode isEqualToString:self.itel]) {
                        [arr removeObject:x];
                    }
                }
                
                NSDictionary *newUser=@{@"itel":self.itel,
                                        @"password":self.password,
                                        @"image":[[dic objectForKey:@"data"] objectForKey:@"photo_file_name"]};
                [arr addObject:newUser];
                 dispatch_async(dispatch_get_main_queue(), ^{
                      self.backUsers=[arr copy];
                 });
               
            });
              
              
          }else{
              [self netRequestFail:dic];
          }
         
         
      }error:^(NSError *error) {
          [self netRequestError:error];
      } completed:^{
          self.busy=@(NO);
      }] ;
       [loginSignal subscribeError:^(NSError *error) {
           self.busy=@(NO);
           [self netRequestError:error];
       }] ;
    
    
}
-(void)didSelectedUser:(NSDictionary*)user{
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        
        self.showTableView=@(NO);
        [self readBackUsers];
        __weak id weakSelf=self;
        [RACObserve(self, backUsers)subscribeNext:^(NSArray *x) {
            __strong LoginViewModel *strongSelf=weakSelf;
            if (x) {
                [strongSelf saveBackUsers];
            }
            
        }];
    }
    return self;
}
-(void)regSuccess:(NSNotification*)notify{
    self.itel=notify.object;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registeSuccess" object:nil];
}
//读备选用户
-(void)readBackUsers{
    NSData *jsonBack=[[NSUserDefaults standardUserDefaults] objectForKey:@"backUsers"];
    NSArray *backUsers=nil;
    if (jsonBack!=nil) {
         backUsers=[NSJSONSerialization JSONObjectWithData:jsonBack options:NSJSONReadingMutableContainers error:nil];
    }
    
   
    if (backUsers) {
        self.backUsers=backUsers;
    }else{
        self.backUsers=[NSArray new];
    }
}
//保存备选用户
-(void)saveBackUsers{
    NSError *error=nil;
    NSData *data=[NSJSONSerialization dataWithJSONObject:self.backUsers options:NSJSONWritingPrettyPrinted error:&error];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"backUsers"];
}
-(void)dealloc{
    NSLog(@"loginViewMode 被销毁");
}
@end
