//
//  ItelUserManager.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelUserManager.h"
static ItelUserManager *manager;
@implementation ItelUserManager
+(ItelUserManager*)defaultManager{
    if (manager==nil) {
        manager=[[ItelUserManager alloc]init];
    }
    return manager;
}
-(void)setHost:(HostItelUser*)host{
    self.hostUser=host;
}
-(void)modifyPersonal:(NSDictionary*)data{
    for(NSString *s in [data allKeys]){
        if ([[data valueForKey:s] isEqual:[NSNull null]]) {
            [data setValue:@"" forKey:s];
        }
    }
    self.hostUser.nickName=[data objectForKey:@"nick_name"];
    self.hostUser.QQ=[data objectForKey:@"qq_num"];
    self.hostUser.sex=[[data objectForKey:@"sex"] boolValue];
    self.hostUser.address=[data objectForKey:@"address"];
    self.hostUser.personalitySignature=[data objectForKey:@"recommend"];
    self.hostUser.email=[data objectForKey:@"mail"];
    self.hostUser.birthDay=[data objectForKey:@"birthday"];
 
}
-(void)callUser:(ItelUser*)user{
    
}

@end
