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
#import "ItelUser+CRUD.h"
@implementation ContactViewModel
-(void)addNewFriend:(ItelUser*)user{
    self.busy=@(YES);
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":user.itelNum};
    __weak ItelUser *blockUser=user;
    
    [[self.requestBuilder addNewFriend:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[x[@"code"]intValue];
        if (code==200) {
            
            
            blockUser.isFriend=@(YES);
            [[DBService defaultService].managedObjectContext save:nil];
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:x[@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
        }else{
            [self netRequestFail:x];
        }
    }error:^(NSError *error) {
        
        self.busy=@(NO);
        [self netRequestError:error];
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
            for (NSDictionary *dic in arr) {
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
- (void)dealloc
{
    NSLog(@"contactViewModel被成功销毁");
}
@end
