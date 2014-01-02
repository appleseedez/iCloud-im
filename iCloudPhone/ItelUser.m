//
//  ItelUser.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "ItelUser.h"

@implementation ItelUser
+(ItelUser*)userWithDictionary:(NSDictionary*)dic{
    for (NSString *key in [dic allKeys]) {
       id object = [dic objectForKey:key];
        if ([object isEqual:[NSNull null]]) {
            [dic setValue:@"" forKey:key];
        }
    }
    
    ItelUser *user=[[ItelUser alloc] init];
    user.itelNum=[dic objectForKey:@"itel"];
    user.userId=[dic objectForKey:@"userId"];
    if (user.userId==nil) {
        user.userId=[dic objectForKey:@"user_id"];
    }
    
    
    user.remarkName=[dic objectForKey:@"alias"];
    
        user.telNum=[dic objectForKey:@"phone"];
    [user setPersonal:dic];
    return user;
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
    self.QQ=[data objectForKey:@"qq_num"];
    self.sex=[[data objectForKey:@"sex"] boolValue];
    self.address=[data objectForKey:@"address"];
    self.personalitySignature=[data objectForKey:@"recommend"];
    self.email=[data objectForKey:@"mail"];
    self.birthDay=[data objectForKey:@"birthday"];
    self.imageurl=[data objectForKey:@"photo_file_name"];
    if ([self.imageurl isEqualToString:@""]) {
        self.imageurl=@"http://www.qqbody.com/uploads/allimg/121207/1ki0it-3.jpg";
    }
    self.address=[data objectForKey:@"area_code"];
}
@end
