//
//  ItelTaskImp.h
//  iCloudPhone
//
//  Created by nsc on 14-4-7.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM (NSInteger, ItelTaskType){
    ItelTaskTypeNet,
    ItelTaskTypeDB,
    ItelTaskTypeResponse,
    ItelTaskTypeError,
    ItelTaskTypeEnd
};
@interface ItelTaskImp : NSObject

@property (nonatomic) ItelTaskType taskType;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) id forResult;
@property (nonatomic,strong) id (^parameterMap)(id forResult);
@property (nonatomic) NSArray *settingParam;
@property (nonatomic) ItelTaskImp *nextTask;
@property (nonatomic) RACSubject *returnSuject;
+(ItelTaskImp*)taskWithType:(ItelTaskType)type;
-(void)setObjectWithParam:(id)param managedObject:(NSManagedObject*)managedObject andContext:(NSManagedObjectContext*)context;
+(ItelTaskImp*)endTask;
@end
