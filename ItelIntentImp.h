//
//  ItelIntentImp.h
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelIntent.h"
@interface ItelIntentImp : NSObject <ItelIntent>
+(id<ItelIntent>)newIntent:(intentType)type;
@property (nonatomic,strong) id <ItelIntent> nextIntent;
@property (nonatomic,weak) id <intentContext> context;
@property (nonatomic,strong) NSDictionary *userInfo;
@end
