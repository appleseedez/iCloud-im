//
//  ItelMessageManager.h
//  iCloudPhone
//
//  Created by nsc on 13-12-30.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelMessage.h"
#import "ItelMessageCache.h"
#import "ItelAction.h"
@interface ItelMessageManager : NSObject <ItelMessageActionDelegate>
@property (nonatomic,strong) ItelMessageCache *systemMessageCache;
@property (nonatomic,strong) NSTimer *timer;
+(ItelMessageManager*)defaultManager;

@end
