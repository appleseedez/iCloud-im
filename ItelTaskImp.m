//
//  ItelTaskImp.m
//  iCloudPhone
//
//  Created by nsc on 14-4-7.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelTaskImp.h"
#import "ItelNetTask.h"
#import "ItelDBTask.h"
#import "ItelResponseTask.h"
@implementation ItelTaskImp


+(ItelTaskImp *)taskWithType:(ItelTaskType)type{
    ItelTaskImp *task;
    switch (type) {
        case ItelTaskTypeNet:{
            task=[[ItelNetTask alloc]init];
            task.taskType=ItelTaskTypeNet;
        
        }
            break;
        case ItelTaskTypeDB:{
            task=[[ItelDBTask alloc]init];
            task.taskType=ItelTaskTypeDB;
      
        }
            break;
        case ItelTaskTypeResponse:{
            task=[[ItelResponseTask alloc]init];
            task.taskType=ItelTaskTypeResponse;
         
        }
            break;
            
        default:
            break;
        }
    
    
    return task;
}
@end
