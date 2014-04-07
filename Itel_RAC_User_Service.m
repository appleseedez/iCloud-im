//
//  Itel_RAC_User_Service.m
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Itel_RAC_User_Service.h"
#import "Itel_User_Intent.h"
#import "RAC_NetRequest_Signal.h"
#import "ReactiveCocoa.h"
#import "ItelTaskImp.h"
#import "RAC_NetRequest_Signal.h"
@implementation Itel_RAC_User_Service
static Itel_RAC_User_Service *defaultService;
+(Itel_RAC_User_Service*)defaultService{
    if (defaultService==nil) {
        //初始化
        defaultService=[[Itel_RAC_User_Service alloc]init];
        defaultService.netSubject=[RACSubject subject];
        defaultService.DBSubjec=[RACSubject subject];
        defaultService.responseSubject=[RACSubject subject];
        defaultService.serviceSubject=[RACSubject subject];
        RACSignal *serviceSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.serviceSubject];
                       return nil;
        }];
        [serviceSignal subscribeError:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        [serviceSignal subscribeNext:^(id <ItelTask> task) {
            //任务分发
            switch (task.taskType) {
                case ItelTaskTypeNet:
                    [defaultService.netSubject sendNext:task];
                    break;
                case ItelTaskTypeDB:
                    [defaultService.DBSubjec sendNext:task];
                    break;
                case ItelTaskTypeResponse:
                    [defaultService.responseSubject sendNext:task];
                    break;
                    
                default:
                    break;
            }
        }];
           //网络请求signal
        RACSignal *netSignal=[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.netSubject];
            return nil;
        }];
        [netSignal subscribeNext:^(id <ItelTask> task) {
            NSString *strUrl=[task.parameters objectForKey:@"url"];
            NSDictionary *parameters=[task.parameters objectForKey:@"parameters" ];
            NSInteger type=[[task.parameters objectForKey:@"type"] integerValue];
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                NSData *responseData;
                NSURLResponse *response;
                NSURLRequest *request;
                if (type==0) {
                    request=[RAC_NetRequest_Signal JSONGetOperation:strUrl parameters:parameters];
                }else if(type==1){
                    request=[RAC_NetRequest_Signal JSONPostOperation:strUrl parameters:parameters];
                }
            responseData=  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (error) {
                    id <ItelTask> errorTask=[ItelTaskImp taskWithType:ItelTaskTypeError];
                    [defaultService.serviceSubject sendNext:errorTask];
                }else {
                    
                    
                    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                     id <ItelTask> nextTask= [task nextTask];
                     //如果还有任务 执行下个task
                    if (nextTask) {
                        nextTask.parameters=nextTask.parameterMap(dic);
                        [defaultService.serviceSubject sendNext:nextTask];
                    }else{
                        //否则执行endTask
                        [defaultService.serviceSubject sendNext:[ItelTaskImp endTask]];
                    }
                }
            });
        }];
        
        // coreData存取
        
    }
    return defaultService;
}


@end
