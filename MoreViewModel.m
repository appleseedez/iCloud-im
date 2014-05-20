//
//  MoreViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreViewModel.h"
#import "AppService.h"
#import "HTTPRequestBuilder+More.h"
@implementation MoreViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appDelegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
        __weak id weekSelf=self;
        [RACObserve(self ,appDelegate.loginInfo) subscribeNext:^(NSDictionary *x) {
            __strong MoreViewModel *strongSelf=weekSelf;
            
            if (x) {
                
            
            strongSelf.itel=x[@"itel"];
            strongSelf.qq=x[@"qq_num"];
            strongSelf.area=x[@"area_code"];
            strongSelf.email=x[@"mail"];
            strongSelf.nickname=x[@"nick_name"];
            strongSelf.birthday=x[@"birthday"];
            strongSelf.phone=x[@"phone"];
            strongSelf.imgUrl=x[@"photo_file_name"];
            strongSelf.sign=x[@"recommend"];
                strongSelf.sex=x[@"sex"];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePhone:) name:@"phoneNumberChanged" object:nil];
    }
    return self;
}
-(void)uploadImage:(NSData*)image{
    self.busy=@(YES);
     NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"itelCode":[self hostItel]};
    NSString *url=[NSString stringWithFormat:@"%@/upload/uploadImg.json",ACCOUNT_SERVER];
         [self.httpService uploadImagePostRequestWithUrl:url imageData:image andParameters:parameters success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
             self.busy=@(NO);
             int code=[[responseObject objectForKey:@"code"]intValue];
             if (code==200) {
                 [[AppService defaultService] setHostWithKey:@"photo_file_name" value:[responseObject objectForKey:@"data"]];
             }else{
                 [self netRequestFail:responseObject];
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self netRequestError:error];
             self.busy=@(NO);
         }];
}
-(void)changePhone:(NSNotification*)notification{
    [[AppService defaultService] setHostWithKey:@"phone" value:notification.object];
}
/*
 "area_code" = "-24181";
 birthday = "1983-03-19";
 domain = "211.149.144.15";
 "is_call" = 0;
 "is_scall" = 0;
 "is_search" = 0;
 "is_shake" = 1;
 "is_sms" = 0;
 "is_voi" = 1;
 itel = 2301031983;
 mail = "<null>";
 "nick_name" = " \U6d41\U6d6a\U7684\U732b";
 phone = 13012360815;
 "photo_file_name" = "http://115.28.21.131:8000/group1/M00/00/05/cxwVg1N0JnaAVeSxAAAm1zkKrKA.header";
 "qq_num" = 41209919;
 sex = 0;
 userId = 258;
 "user_type" = 0;
 */
-(void)modifyHoseSetting:(NSString*)key value:(NSString*)value{
    self.busy=@(YES);
  
    NSDictionary *parameters=@{@"userId":[self hostUserID] ,@"itel":[self hostItel],@"key":key,@"value":value};
    [[self.requestBuilder modifyHost:parameters] subscribeNext:^(NSDictionary *x) {
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            NSDictionary *data=x[@"data"];
            for (NSString *k in data.allKeys) {
                id dvalue= data[k];
                if (![dvalue isEqual:[NSNull null]]) {
                    [[AppService defaultService] setHostWithKey:k value:dvalue];

                }
                            }
            
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
- (void)dealloc
{
    NSLog(@"moreViewModel成功被销毁");
}
@end
