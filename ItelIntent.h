//
//  ItelIntent.h
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "intentContext.h"

@protocol intentContext;
typedef NS_ENUM(NSInteger, intentType) {
    intentTypeMessage = 1,
    intentTypeNextStep = 1 << 1,
    intentTypeReloadData=2 << 1
};

@protocol ItelIntent <NSObject>

@optional

+(id<ItelIntent>)newIntent:(intentType)type;

@required
-(void)start;
-(void)dependenceInjection:(id<intentContext>)context;
@property (nonatomic,strong) id <ItelIntent> nextIntent;
@property (nonatomic,weak) id <intentContext> context;
@property (nonatomic,strong) NSDictionary *userInfo;
@end
