//
//  ItelTaskImp.h
//  iCloudPhone
//
//  Created by nsc on 14-4-7.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelTask.h"
@interface ItelTaskImp : NSObject <ItelTask>


@property (nonatomic) ItelTaskType taskType;
@property (nonatomic) NSDictionary *parameters;

+(id<ItelTask>)taskWithType:(ItelTaskType)type;

-(id<ItelTask>)nextTask;
+(id<ItelTask>)endTask;
@end
