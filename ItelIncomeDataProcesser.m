//
//  ItelIncomeDataProcesser.m
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelIncomeDataProcesser.h"

@implementation ItelIncomeDataProcesser
-(void)buildMudel{
   
    self.outSessionInit=[RACSubject subject];
    self.failSession=[RACSubject subject];
    self.receiveAnswering=[RACSubject subject];
    self.receiveCalling=[RACSubject subject];
    self.loginSuccess=[RACSubject subject];
    self.periodHalt=[RACSubject subject];
    self.droppedFramSignal=[RACSubject subject];
    self.heartBeat=[RACSubject subject];
   
     [self.incomeData subscribeNext:^(NSDictionary *data) {
         
         NSInteger type = -1;
         //具体的数据
         NSDictionary *bodySection = @{};
         // 以是否具有head块作为解析依据。
         
         // 获取头部数据
         NSDictionary *headSection = [data valueForKey:kHead];
         if (headSection) {
             type = [[headSection valueForKey:kType] integerValue];
             NSInteger status = [[headSection valueForKey:kStatus] integerValue];
             // 异常情况处理。
             if (status != NORMAL_STATUS) {
                 [NSException exceptionWithName:@"500:data format error"
                                         reason:@"信令服务器返回数据状态不正常"
                                       userInfo:nil];
                 //如果收到的status不正常, 则触发该消息
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:SIGNAL_ERROR_NOTIFICATION
                  object:nil
                  userInfo:@{ kType : @(type) }];
                 [self.failSession sendNext:data];
                 return;
             }
             bodySection = [data valueForKey:kBody];
         } else {
             type = [[data valueForKey:kType] integerValue];
             bodySection = data;
         }
         RACSubject *outSubject;
         //路由
         switch (type) {
             case SESSION_INIT_RES_TYPE:
                 // 通话查询请求正常返回，通知业务层
                 // [self sessionInited:]
                 outSubject=self.outSessionInit;
                 break;
             case SESSION_PERIOD_CALLING_TYPE:
                 outSubject=self.receiveCalling;
                 break;
             case SESSION_PERIOD_ANSWERING_TYPE:
                 outSubject=self.receiveAnswering;
                 break;
             case CMID_APP_LOGIN_SSS_RESP_TYPE: //信令服务器验证响应返回了，通知业务层
                 outSubject=self.loginSuccess;
                 break;
             case SESSION_PERIOD_HALT_TYPE:
                 outSubject=self.periodHalt;
                 break;
             case CMID_APP_DROPPED_SSS_REQ_TYPE:
                 outSubject=self.droppedFramSignal;
                 break;
             case HEART_BEAT_REQ_TYPE:
                 outSubject=self.heartBeat;
                 
                 break;
             default:
                 break;
         }
         [outSubject sendNext:bodySection];
         
         
     }];
}
@end
