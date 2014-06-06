//
//  ItelUser+CRUD.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelUser+CRUD.h"
#import "DBService.h"
#import "pinyin.h"
#import "NXInputChecker.h"
@implementation ItelUser (CRUD)

+(ItelUser*)userWithItel:(NSString*)itel{
    NSError* error;
    ItelUser *user;
    NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
    NSFetchRequest* getOneUser = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
    getOneUser.predicate = [NSPredicate predicateWithFormat:@"itelNum = %@",itel];
    
    NSArray* match = [context executeFetchRequest:getOneUser error:&error];
    if ([match count]) {
        user =(ItelUser*)match[0];
    }
    return user;
}
+(ItelUser*)userWithDictionary:(NSDictionary*)dic inContext:(NSManagedObjectContext*) context{
    for (NSString *key in [dic allKeys]) {
        id object = [dic objectForKey:key];
        if ([object isEqual:[NSNull null]]) {
            [dic setValue:@"" forKey:key];
        }
    }

    NSString* itelNumber = [dic objectForKey:@"itel"];
    NSError* error;
    ItelUser *user;

    NSFetchRequest* getOneUser = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
    getOneUser.predicate = [NSPredicate predicateWithFormat:@"itelNum = %@",itelNumber];
    
    NSArray* match = [context executeFetchRequest:getOneUser error:&error];
    if ([match count]) {
        user =(ItelUser*)match[0];
    }else{
        user= [NSEntityDescription insertNewObjectForEntityForName:@"ItelUser" inManagedObjectContext:context];
    }


    user.itelNum=[dic objectForKey:@"itel"];
    user.userId=[NSString stringWithFormat:@"%@",[dic objectForKey:@"userId"]];
    if (user.userId==nil) {
        user.userId=[NSString stringWithFormat:@"%@",[dic objectForKey:@"user_id"]] ;
    }
    user.remarkName=[dic objectForKey:@"alias"] ;
    user.telNum=[dic objectForKey:@"phone"];
    
    [user setPersonal:dic];
    NSString *pynick=@"";
    if ([NXInputChecker checkEmpty:user.nickName]) {
        for (int i=0; i<user.nickName.length; i++) {
            char letter= [Pinyin getFirstLetter:user.nickName];
            if (letter!='#') {
            pynick=[NSString stringWithFormat:@"%@%c",pynick,letter];
            }else{
                NSString *s=nil;
                NSRange range;
                range.length=1;
                range.location=i;
                s=[user.nickName substringWithRange:range];
                pynick=[NSString stringWithFormat:@"%@%@",pynick,s];

            }
        }
    }
    user.pyNickname=pynick;
    NSString *remark=@"";
    if ([user.remarkName length]) {
        for (int i=0; i<user.remarkName.length; i++) {
             char letter= [Pinyin getFirstLetter:user.remarkName];
            if (letter!='#') {
                remark=[NSString stringWithFormat:@"%@%c",remark,letter];
            }else{
                NSString *s=nil;
                NSRange range;
                range.length=1;
                range.location=i;
                s=[user.remarkName substringWithRange:range];
                remark=[NSString stringWithFormat:@"%@%@",remark,s];
            }
            
        }
    }
    user.pyRemarkName=remark;
    NSString *resource=nil;
    if (user.pyRemarkName.length) {
        resource=user.pyRemarkName;
    }else{
        resource=user.pyNickname;
    }
    if (resource.length) {
        NSRange range;
        range.length=1;
        range.location=0;
        NSString *first=[[resource substringWithRange:range] lowercaseString];
        
        NSString *regex = @"[a-z]";
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", first];
        
        if ([predicate evaluateWithObject:first] == YES) {
            user.section=first;
        }else{
               regex=@"[0-9]";
            NSPredicate *predicate0 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", first];
            if ([predicate0 evaluateWithObject:first]) {//如果是数字
                  user.section=@"0";
            }else{
                user.section=@"#";
            }
        }
    }
    if (!user.nickName.length && !user.remarkName.length) {
        user.section=@"0";
    }
    //全拼
    NSString *quanpin=nil;
    if ([NXInputChecker checkEmpty:user.remarkName]) {
        quanpin=user.remarkName;
    }else{
        quanpin=user.nickName;
    }
    
   // NSLog(@" name:%@ section:%@   nickname:%@   remarkname:%@",resource,user.section,user.nickName,user.remarkName);
    
    return user;
}
-(void)setPersonal:(NSDictionary*)data{
    for(NSString *s in [data allKeys]){
        if ([[data valueForKey:s] isEqual:[NSNull null]]) {
            [data setValue:@"" forKey:s];
        }
    }
    NSString* nickName = [data objectForKey:@"nick_name"];
    if (!nickName) {
       nickName =[data objectForKey:@"nickname"];
    }
    self.nickName = nickName;
    self.qq=[data objectForKey:@"qq_num"];
    self.sex=[NSNumber numberWithBool:[[data objectForKey:@"sex"] boolValue]];
    self.address=[data objectForKey:@"address"];
    self.personalitySignature=[data objectForKey:@"recommend"];
    self.email=[data objectForKey:@"mail"];
    self.birthDay=[data objectForKey:@"birthday"];
    self.imageurl=[data objectForKey:@"photo_file_name"];


    self.address=[data objectForKey:@"area_code"];
   
   // self.host = hostUser;
}

- (void)delete{

}
@end
