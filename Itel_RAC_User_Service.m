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
#import "ItelNetTask.h"
#import "ItelDBTask.h"
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
        [netSignal subscribeNext:^(ItelNetTask *task) {
            NSString *strUrl=task.url;
            NSDictionary *parameters=task.parameters;
            NSInteger type=task.requestType;
            dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSError *error;
                NSData *responseData;
                NSURLResponse *response;
                NSURLRequest *request;
                if (type==ItelNetTaskRequestTypeGet) {
                    request=[RAC_NetRequest_builder JSONGetOperation:strUrl parameters:parameters];
                }else if(type==ItelNetTaskRequestTypeJsonPost){
                    request=[RAC_NetRequest_builder JSONPostOperation:strUrl parameters:parameters];
                }
            responseData=  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                if (error) {
                    [task.requestError sendNext:error];
                }else {
                    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                    NSString *keypath=task.codeKeyPath;
                    if (keypath==nil) {
                         keypath=@"code";
                    }
                    int code=[[dic valueForKeyPath:keypath]intValue];
                    if (code==200) {
                        [task.returnSuject sendNext:dic];
                        
                    }else{
                        [task.failuerSubject sendNext:dic];
                    }
                    
                    
                    
                    
                }
            });
        }];
        
        // coreData存取
        RACSignal *DBSignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:defaultService.DBSubjec];
            return nil;
        }]flatten];
        [DBSignal subscribeNext:^(ItelDBTask *task) {
            NSString *selectName=task.selectName;
           // NSString *predicateName=[task.parameters objectForKey:@"predicate"];
            NSManagedObjectContext *context=[IMCoreDataManager defaulManager].managedObjectContext;
                            NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:selectName];
                NSError *error;
            NSString *selectParam=[NSString stringWithFormat:@"%@ = %@",task.predicateName ,task.predicateValue ];
            
                request.predicate = [NSPredicate predicateWithFormat:selectParam];
            
             
                NSArray* matched = [context executeFetchRequest:request error:&error];
                if (error) {
                    [task.returnSuject sendError:error];
                }
                if ([matched count]) {
                   NSManagedObject *managedObject = matched[0];
                    [task.returnSuject sendNext:managedObject];
                }else{
                    [task.returnSuject sendNext:@(0)];
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
