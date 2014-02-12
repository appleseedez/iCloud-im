//
//  ItelProcessIntent.m
//  iCloudPhone
//
//  Created by nsc on 14-2-10.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelProcessIntent.h"

@implementation ItelProcessIntent
-(void)start{
    [self.context goForewardStep:self.userInfo];
}
@end
