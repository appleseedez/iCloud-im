//
//  ItelUserInterfaceImp.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelUserInterfaceImp.h"
#import "IMCoreDataManager.h"
static NSString* kCurrentUser = @"currUser";
@implementation ItelUserInterfaceImp
//本机用户
-(HostItelUser*)hostUser{
    NSString* currUserItemNum = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUser];
    //
    NSAssert([currUserItemNum intValue] != 0, @"NSUserDefaults 拿不到currUser");
    NSError* error = nil;
    NSFetchRequest* getCurrentUser = [NSFetchRequest fetchRequestWithEntityName:@"HostItelUser"];
    getCurrentUser.predicate = [NSPredicate predicateWithFormat:@"itelNum = %@",currUserItemNum];
    NSArray* currentUsers = [[IMCoreDataManager defaulManager].managedObjectContext executeFetchRequest:getCurrentUser error:&error];
    
    HostItelUser* currentUser = currentUsers[0];
    return currentUser;
}
//设置本机用户
-(void)setHost:(HostItelUser*)host{
    //登陆成功后,会从服务端获取到登陆用户的信息. 信息已经保存到coredata,此处只是保留一个itelnumber作为查询使用
    [[NSUserDefaults standardUserDefaults] setObject:host.itelNum forKey:kCurrentUser];
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

@end
