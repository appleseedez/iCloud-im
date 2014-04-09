//
//  ItelDBTask.m
//  iCloudPhone
//
//  Created by nsc on 14-4-8.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelDBTask.h"

@implementation ItelDBTask
-(ItelDBTask*)buildGetHostTask{
    
        self.selectName=@"HostItelUser";
        self.predicateName=@"itelNum";
    
        self.predicateValue= [[NSUserDefaults standardUserDefaults] objectForKey:@"currUser"];
    if (self.predicateValue==nil) {
        return nil;
    }
    return self;
}
@end
