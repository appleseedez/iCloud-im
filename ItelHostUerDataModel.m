//
//  ItelHostUerDataModel.m
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelHostUerDataModel.h"
#import "ItelTaskImp.h"
#import "Itel_RAC_User_Service.h"
#import "ItelAction.h"
#import "ItelResponseTask.h"
@implementation ItelHostUerDataModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inModifySubject=[RACSubject subject];
        self.outSubject =[RACSubject subject];
           RACSignal *modifySignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
               [subscriber sendNext:self.inModifySubject];
               return nil;
           }]flatten];
           [modifySignal subscribeNext:^(NSDictionary *param) {
               ItelTaskImp *netTask=[self buildNetRequestTask:param ];
               netTask.nextTask=[self buildDBSaveTask];
               netTask.nextTask.nextTask=[self buildResponseTask];
               [[Itel_RAC_User_Service defaultService].serviceSubject sendNext:netTask];
               
           }];
        
    }
    return self;
}
-(ItelTaskImp *)buildNetRequestTask:(NSDictionary*)param{
    /*
        url:请求网址
        parameters: 请求参数
        type:请求类型
     
     */
    HostItelUser *hostUser=[[ItelAction action] getHost];
    NSString *key=[param objectForKey:@"key"];
    NSString *value=[param objectForKey:@"value"];
    ItelTaskImp *netTask=[ItelTaskImp taskWithType:ItelTaskTypeNet];
    NSDictionary *parameters = @{@"userId":hostUser.userId ,@"itel":hostUser.itelNum,@"token":hostUser.token,@"key":key,@"value":value};
    NSString *url=[NSString stringWithFormat:@"%@/user/updateUser.json",SIGNAL_SERVER];
    netTask.parameters=@{@"url":url,@"parameters":parameters,@"type":@(1)};
    return netTask;
}
-(ItelTaskImp *)buildDBSaveTask{
    /*
      selectName: 表名称
      predicate : 查询字段名称
      selectParam:查询字段value
     */

    NSDictionary *parameters=@{@"selectName": @"HostItelUser",@"predicate":@"itelNum",@"selectParam":@"itel"};
    ItelTaskImp *task= [ItelTaskImp taskWithType:ItelTaskTypeDB];
    task.parameters=parameters;
    task.parameterMap=^id(id forResult){
        
        
        return @[[forResult valueForKey:@"data"]];
    };
    return task;
}
-(ItelTaskImp *)buildResponseTask{
    ItelResponseTask *task=(ItelResponseTask*)[ItelTaskImp taskWithType:ItelTaskTypeResponse];
    
    task.responseSubject=self.outSubject;
    return task;
}
@end
