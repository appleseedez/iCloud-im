//
//  ItelUserManager.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelUserManager.h"
#import "IMCoreDataManager.h"
static ItelUserManager *manager;
@implementation ItelUserManager
+ (void)initialize{
    if (manager==nil) {
        manager=[[ItelUserManager alloc]init];
    }
}
+(ItelUserManager*)defaultManager{

    return manager;
}
-(void)tearDown{
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
    self.hostUser.qq=[data objectForKey:@"qq_num"];
    NSNumber *sex=[NSNumber numberWithBool:[[data objectForKey:@"sex"] boolValue]];
    self.hostUser.sex=sex;
    self.hostUser.address=[data objectForKey:@"address"];
    self.hostUser.personalitySignature=[data objectForKey:@"recommend"];
    self.hostUser.email=[data objectForKey:@"mail"];
    self.hostUser.birthday=[data objectForKey:@"birthday"];
    
    [[IMCoreDataManager defaulManager]saveContext];
}
-(void)callUser:(ItelUser*)user{
    
}

@end
