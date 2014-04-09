//
//  ItelViewModelManager.h
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelHostUerDataModel.h"
@interface ItelViewModelManager : NSObject
@property (nonatomic,strong)ItelHostUerDataModel *hostModel;

+(instancetype)defaultManager;

@end
