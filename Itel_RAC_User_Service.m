//
//  Itel_RAC_User_Service.m
//  iCloudPhone
//
//  Created by nsc on 14-4-6.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Itel_RAC_User_Service.h"

#import "RAC_NetRequest_builder.h"
#import "ReactiveCocoa.h"
#import "ItelTaskImp.h"
#import "NSManagedObject+RAC.h"
#import "IMCoreDataManager+FMDB_TO_COREDATA.h"
#import "ItelResponseTask.h"
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
        RACSignal *serviceSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.serviceSubject];
                       return nil;
        }]flatten];
        [serviceSignal subscribeError:^(NSError *error) {
            NSLog(@"%@",error);
        }];
        [serviceSignal subscribeNext:^(ItelTaskImp *task) {
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
        RACSignal *netSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.netSubject];
            return nil;
        }]flatten];
        [netSignal subscribeNext:^(ItelTaskImp *task) {
            NSString *strUrl=[task.parameters objectForKey:@"url"];
            NSDictionary *parameters=[task.parameters objectForKey:@"parameters" ];
            NSInteger type=[[task.parameters objectForKey:@"type"] integerValue];
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                NSData *responseData;
                NSURLResponse *response;
                NSURLRequest *request;
                if (type==0) {
                    request=[RAC_NetRequest_builder JSONGetOperation:strUrl parameters:parameters];
                }else if(type==1){
                    request=[RAC_NetRequest_builder JSONPostOperation:strUrl parameters:parameters];
                }
            responseData=  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (error) {
                    ItelTaskImp *errorTask=[ItelTaskImp taskWithType:ItelTaskTypeError];
                    [defaultService.serviceSubject sendNext:errorTask];
                }else {
                    
                    
                    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                     ItelTaskImp *nextTask= [task nextTask];
                     //如果还有任务 执行下个task
                    if (nextTask) {
                        nextTask.forResult=dic;
                        nextTask.settingParam=nextTask.parameterMap(dic);
                        [defaultService.serviceSubject sendNext:nextTask];
                    }else{
                        //否则执行endTask
                        [defaultService.serviceSubject sendNext:[ItelTaskImp endTask]];
                    }
                }
            });
        }];
        
        // coreData存取
        RACSignal *DBSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.DBSubjec];
            return nil;
        }]flatten];
        [DBSignal subscribeNext:^(ItelTaskImp *task) {
            NSString *selectName=[task.parameters objectForKey:@"selectName"];
            NSString *predicateName=[task.parameters objectForKey:@"predicate"];
            NSManagedObjectContext *context=[IMCoreDataManager defaulManager].managedObjectContext;
            for (id object in task.settingParam) {
                NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:selectName];
                NSError *error;
                NSString *selectParam=[NSString stringWithFormat:@"%@ = %@",predicateName,[object valueForKey:[task.parameters valueForKey:@"selectParam"] ]];
                
                request.predicate = [NSPredicate predicateWithFormat:selectParam];
                NSLog(@"%@ = %@",predicateName,[object valueForKey:[task.parameters valueForKey:@"selectParam"] ]);
             
                NSArray* matched = [context executeFetchRequest:request error:&error];
                if (error) {
                    NSLog(@"%@",error);
                }
                if ([matched count]) {
                   NSManagedObject *managedObject = matched[0];
                    [managedObject setWithDic:object andContext:context];
                }else{
                     id managedObject= [NSEntityDescription insertNewObjectForEntityForName:selectName inManagedObjectContext:context];
                    [managedObject setWithDic:object andContext:context];
                }

            }
            ItelTaskImp *nextTask= [task nextTask];
            nextTask.forResult=task.forResult;
            if (nextTask) {
                [defaultService.serviceSubject sendNext:nextTask];
            }
            
        }];
        
        RACSignal *responseSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.responseSubject];
            return nil;
        }]flatten];
        
            [responseSignal subscribeNext:^(ItelResponseTask *task) {
                [task.responseSubject sendNext:task.forResult];
                
            }];
        
        
        
    }
    return defaultService;
}


@end
