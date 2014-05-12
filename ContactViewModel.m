//
//  ContactViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "ContactViewModel.h"
#import "HTTPRequestBuilder+contact.h"
#import "ItelUser+CRUD.h"
#import "DBService.h"
@implementation ContactViewModel
-(void)addNewFriend:(NSString*)itel{
    self.busy=@(YES);
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":itel};
    [[self.requestBuilder addNewFriend:parameters] subscribeNext:^(id x) {
        
    }error:^(NSError *error) {
        
    }completed:^{
        self.busy=@(NO);
    }];
}
-(void)refreshFriendList{
     NSDictionary *parameters = @{@"keyWord":[self hostUserID] ,@"start":@(0),@"limit":@(1500)};
    self.busy=@(YES);
    [[self.requestBuilder getFriendList:parameters] subscribeNext:^(NSDictionary *x) {
        int code=[x[@"code"] intValue];
        if (code==200) {
            NSArray *arr=[x[@"data"] objectForKey:@"list"];
            NSManagedObjectContext *contex=[DBService defaultService].managedObjectContext;
            for (NSDictionary *dic in arr ) {
              ItelUser *user= [ItelUser userWithDictionary:dic inContext:contex];
                user.isFriend=@(YES);
                user.host=[self hostItel];
                NSError *error=nil;
                [contex save:&error];
                if (error) {
                    NSLog(@"%@",error);
                }
            }
           
            
        }else{
            [self netRequestFail:x];
        }
    }error:^(NSError *error) {
        self.busy=@(NO);
    }completed:^{
        self.busy=@(NO);
    }];
}
@end
