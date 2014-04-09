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
#import "ItelNetTask.h"
#import "HostItelUser+set.h"
#import "ItelDBTask.h"

#import "IMCoreDataManager+FMDB_TO_COREDATA.h"
@implementation ItelHostUerDataModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.inModifySubject=[RACSubject subject];
        self.outSubject =[RACSubject subject];
        RACSubject *netFailureSubject=[RACSubject subject];
        RACSubject *netResponseSubject=[RACSubject subject ];
        RACSubject *getHostSubject=[RACSubject subject];
        //网络请求信号
           RACSignal *modifySignal=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
               [subscriber sendNext:self.inModifySubject];
               return nil;
           }]flatten];
           [modifySignal subscribeNext:^(NSDictionary *param) {
               ItelNetTask *netTask=(ItelNetTask*)[ItelTaskImp taskWithType:ItelTaskTypeNet];
               [netTask buildWithInterFace:ItelNetTaskInterfaceUpdateUser userInfo:param];
               netTask.returnSuject=netResponseSubject;
               netTask.failuerSubject=netFailureSubject;
               [[Itel_RAC_User_Service defaultService].serviceSubject sendNext:netTask];
               //获得hostUser
               ItelDBTask *hostTask=[(ItelDBTask*)[ItelTaskImp taskWithType:ItelTaskTypeDB] buildGetHostTask];
               hostTask.returnSuject=getHostSubject;
               [[Itel_RAC_User_Service defaultService].serviceSubject sendNext: hostTask];

               
            }];
        
        
        [modifySignal subscribeError:^(NSError *error) {
              
        }];
        //网络请求回调
        //失败
         RACSignal *requestFail=[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
             [subscriber sendNext:netFailureSubject];
             return nil;
         }]flatten];
                [requestFail subscribeNext:^(NSDictionary *dic) {
                    // 这里写失败的回调
                }];
        
        
        //成功
        
        RACSignal *netResponseSignal=[RACSignal combineLatest:@[netResponseSubject,getHostSubject]];
        
        [netResponseSignal subscribeNext:^(RACTuple *tuple) {
            NSDictionary *dic=[tuple objectAtIndex:0];
            HostItelUser *hoseUser=[tuple objectAtIndex:1];
            [hoseUser setPersonal:[dic objectForKey:@"data"]];
            NSError *saveError;
            [[IMCoreDataManager defaulManager ].managedObjectContext save:&saveError];
            if (saveError) {
                NSLog(@"%@",saveError);
            }
            [self.outSubject sendNext:@(1)];
        }];
    }
    return self;
}

@end
