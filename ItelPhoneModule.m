//
//  ItelPhoneModule.m
//  iCloudPhone
//
//  Created by nsc on 14-4-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelPhoneModule.h"
#import "ItelSocketConnector.h"
#import "IMSeqenceGen.h"
#import "ItelAction.h"
#import "ItelIncomeDataProcesser.h"
#import "IMSessionInitMessageBuilder.h"
#import "NSCAppDelegate.h"
@implementation ItelPhoneModule
+(ItelPhoneModule*)getPhoneModule{
    return ((NSCAppDelegate*)[UIApplication sharedApplication].delegate).phoneModule;
}
-(void)buildModule{
    [self buildInternal];
    
    [self.inConnect subscribeNext:^(id x) {
        
        NSDictionary *params=@{@"account":[[ItelAction action]getHost].itelNum,@"clientstatus":@(0),@"clienttype":@(1),@"token":@""};
        
        NSDictionary *authInfo=@{
                                 kHead:@{
                                         kType: [NSNumber numberWithInt:CMID_APP_LOGIN_SSS_REQ_TYPE],
                                         kStatus:[NSNumber numberWithInt:NORMAL_STATUS],
                                         kSeq:[NSNumber numberWithInteger:[IMSeqenceGen seq]]
                                         },
                                 kBody:params
                                 
                                 };;
        [self.socketConnector.inConnect sendNext:authInfo];
    }];
}
-(void)buildInternal{
    //建立模块连接
       //tcp连接器
    self.socketConnector =[[ItelSocketConnector alloc]init];
    [self.socketConnector buildModule];
       //tcp返回数据处理器
    self.incomeDataProcesser=[[ItelIncomeDataProcesser alloc]init];
     self.incomeDataProcesser.incomeData=self.socketConnector.inData;
    [self.incomeDataProcesser buildMudel];
        
     //打电话接口
    [self buildCall];
    
    
    self.inConnect=[RACSubject subject];
    
}
-(void)buildCall{
    self.outCall=[RACSubject subject];
     [self.outCall subscribeNext:^(NSString *destAccount) {
         NSDictionary *data=[[[IMSessionInitMessageBuilder alloc]init]buildWithParams:@{kDestAccount : destAccount }];
         [self.socketConnector.outData sendNext:data];
    }];

}
@end
