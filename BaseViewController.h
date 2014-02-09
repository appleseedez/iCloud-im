//
//  BaseViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "intentContext.h"
@interface BaseViewController : UIViewController <intentContext>
@property (nonatomic,strong) id <ItelIntent> currIntent;
@property (nonatomic,strong) NSArray *notifications;
@end
