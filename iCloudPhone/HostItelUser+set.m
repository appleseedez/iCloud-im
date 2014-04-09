//
//  HostItelUser.m
//  iCloudPhone
//
//  Created by nsc on 13-11-21.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "HostItelUser+set.h"
#import "IMCoreDataManager.h"
#import "NSManagedObject+RAC.h"
@implementation HostItelUser (set)
+(HostItelUser*)userWithDictionary:(NSDictionary*)dic{
    NSManagedObjectContext* currentContext = [IMCoreDataManager defaulManager].managedObjectContext;
    HostItelUser* host = nil;
    if (currentContext) {
            host = [NSEntityDescription insertNewObjectForEntityForName:@"HostItelUser" inManagedObjectContext:currentContext];
            host.domain =[dic objectForKey:@"domain"];
            
            NSNumber *port = [dic objectForKey:@"port"];
            host.port=[NSString stringWithFormat:@"%@",port ];
            host.stunServer=[dic objectForKey:@"stun_server"];
            NSString *token=[dic objectForKey:@"sessiontoken"];
            if ([token isEqual: [NSNull null]]||token==nil) {
                host.token=@"djsadfkjafaklfji";
                
            }
            else {
                host.token=token;
            }
            host.itelNum=[dic objectForKey:@"itel"];
            
            host.userId=[NSString stringWithFormat:@"%@",[dic objectForKey:@"userId"]];
            
            host.telNum=[dic objectForKey:@"phone"];
            
            host.countType=[NSNumber numberWithBool:[[dic objectForKey:@"user_type"] boolValue]];
            [host setPersonal:dic];
            [[IMCoreDataManager defaulManager] saveContext:host.managedObjectContext];
    }



    return host;
}
-(void)setWithDic:(NSDictionary *)dic andContext:(NSManagedObjectContext *)context{
    [self setPersonal:dic];
    NSError *error;
    [context save:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    
}
-(void)setPersonal:(NSDictionary*)data{
    for(NSString *s in [data allKeys]){
        if ([[data valueForKey:s] isEqual:[NSNull null]]) {
            [data setValue:@"" forKey:s];
        }
    }
    self.nickName=[data objectForKey:@"nick_name"];
    if (!self.nickName) {
        self.nickName = [data objectForKey:@"nickname"];
    }
    self.qq=[data objectForKey:@"qq_num"];
    self.sex=[NSNumber numberWithBool:[[data objectForKey:@"sex"] boolValue]];
    self.address=[data objectForKey:@"address"];
    self.personalitySignature=[data objectForKey:@"recommend"];
    self.email=[data objectForKey:@"mail"];
    self.birthday=[data objectForKey:@"birthday"];
    self.imageUrl=[data objectForKey:@"photo_file_name"];
    if ([self.imageUrl isEqualToString:@""]) {
        self.imageUrl=@"http://www.qqbody.com/uploads/allimg/121207/1ki0it-3.jpg";
    }
    self.address=[data objectForKey:@"area_code"];
}

@end
