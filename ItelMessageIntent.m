//
//  ItelMessageIntent.m
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelMessageIntent.h"

@implementation ItelMessageIntent 

-(void)start{
    [self.context mentionMessage:self.userInfo];
}

@end
