//
//  ItelViewModelManager.m
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelViewModelManager.h"

@implementation ItelViewModelManager
static ItelViewModelManager *instance;

+(instancetype)defaultManager{
    return instance;
}
+ (void)initialize {
    instance = [ItelViewModelManager new];
    instance.hostModel=[[ItelHostUerDataModel alloc]init];
}
@end
