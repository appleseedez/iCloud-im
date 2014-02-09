//
//  ItelIntentRefreshData.m
//  iCloudPhone
//
//  Created by nsc on 14-2-9.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelIntentRefreshData.h"

@implementation ItelIntentRefreshData
-(void)start{
    [self.context reloadData:self.userInfo];
}
@end
