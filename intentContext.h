//
//  intentContext.h
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItelIntent.h"

@protocol ItelIntent;


@protocol intentContext <NSObject>
@optional

#pragma mark - viewControllerMethods
-(void) mentionMessage:(id)message;
-(void) goForewardStep:(id)userInfo;
-(void) reloadData:(id)userInfo;
#pragma mark - step methods
-(void) intentEnd:(id <ItelIntent> )intent;
@end
