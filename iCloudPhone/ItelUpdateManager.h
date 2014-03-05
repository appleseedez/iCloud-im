//
//  ItelUpdateManager.h
//  iCloudPhone
//
//  Created by nsc on 14-3-5.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItelUpdateManager : NSObject <UIAlertViewDelegate>
+(ItelUpdateManager*)defaultManager;
@property (nonatomic) NSString *updateUrl;
-(void)checkUpdate;
@end
