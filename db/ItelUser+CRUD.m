//
//  ItelUser+CRUD.m
//  iCloudPhone
//
//  Created by Pharaoh on 1/7/14.
//  Copyright (c) 2014 NX. All rights reserved.
//

#import "ItelUser+CRUD.h"
#import "IMCoreDataManager.h"
@implementation ItelUser (CRUD)
+(ItelUser*)userWithDictionary:(NSDictionary*)dic{
    for (NSString *key in [dic allKeys]) {
        id object = [dic objectForKey:key];
        if ([object isEqual:[NSNull null]]) {
            [dic setValue:@"" forKey:key];
        }
    }
    NSError* error;
    ItelUser *user;
    NSString* itelNumber = [[dic objectForKey:@"itel"] stringValue];
    NSFetchRequest* getOneUser = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
    getOneUser.predicate = [NSPredicate predicateWithFormat:@"itelNum = %@",itelNumber];
    
    NSArray* match = [[IMCoreDataManager defaulManager].managedObjectContext executeFetchRequest:getOneUser error:&error];
    if ([match count]) {
        user =(ItelUser*)match[0];
    }else{
        user= [NSEntityDescription insertNewObjectForEntityForName:@"ItelUser" inManagedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext];
    }

    user.itelNum=[[dic objectForKey:@"itel"] stringValue];
    user.userId=[[dic objectForKey:@"userId"] stringValue];
    if (user.userId==nil) {
        user.userId=[[dic objectForKey:@"user_id"] stringValue];
    }
    user.remarkName=[[dic objectForKey:@"alias"] stringValue];
    user.telNum=[[dic objectForKey:@"phone"] stringValue];
    //
    [user setPersonal:dic];
    return user;
}
-(void)setPersonal:(NSDictionary*)data{
    for(NSString *s in [data allKeys]){
        if ([[data valueForKey:s] isEqual:[NSNull null]]) {
            [data setValue:@"" forKey:s];
        }
    }
    NSString* nickName = [[data objectForKey:@"nick_name"] stringValue];
    if (!nickName) {
       nickName =[data objectForKey:@"nickname"];
    }
    self.nickName = nickName;
    self.qq=[[data objectForKey:@"qq_num"] stringValue];
    self.sex=[NSNumber numberWithBool:[[data objectForKey:@"sex"] boolValue]];
    self.address=[[data objectForKey:@"address"] stringValue];
    self.personalitySignature=[[data objectForKey:@"recommend"] stringValue];
    self.email=[[data objectForKey:@"mail"] stringValue];
    self.birthDay=[[data objectForKey:@"birthday"] stringValue];
    self.imageurl=[[data objectForKey:@"photo_file_name"] stringValue];
    if ([self.imageurl isEqualToString:@""]) {
        self.imageurl=@"http://www.qqbody.com/uploads/allimg/121207/1ki0it-3.jpg";
    }
    self.address=[[data objectForKey:@"area_code"] stringValue];
    [[IMCoreDataManager defaulManager] saveContext];
}
@end
