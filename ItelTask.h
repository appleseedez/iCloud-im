//
//  ItelTask.h
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

@protocol ItelTask <NSObject>

@property (nonatomic) ItelTaskType taskType;
@property (nonatomic) NSDictionary *parameters;
@property (nonatomic) id forResult;
@property (nonatomic) id (^parameterMap)(id forResult);
+(id<ItelTask>)taskWithType:(ItelTaskType)type;

-(id<ItelTask>)nextTask;
+(id<ItelTask>)endTask;
@end
