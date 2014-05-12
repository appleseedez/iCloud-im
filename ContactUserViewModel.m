//
//  ContactUserViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-12.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "ContactUserViewModel.h"
#import "HTTPRequestBuilder+contact.h"
#import "DBService.h"
@implementation ContactUserViewModel
-(void)editAlias:(NSString*)newAlias{
    self.busy=@(YES);
       NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":self.user.itelNum,@"alias":newAlias};
    [[self.requestBuilder editUserAlias:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[x[@"code"]intValue];
        if (code==200) {
            NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
            self.user=[ItelUser userWithDictionary:x[@"data"] inContext:context ];
            [context save:nil];
            
        }else{
            [self netRequestFail:x];
        }
        
    }error:^(NSError *error) {
        [self netRequestError:error];
        self.busy=@(NO);
    }completed:^{
        self.busy=@(NO);
    }];
}
-(void)delUser{
       NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":self.user.itelNum};
          [[self.requestBuilder delFriend:parameters] subscribeNext:^(id x) {
              
              if (![x isKindOfClass:[NSDictionary class]]) {
                  [self responseError:x];
                  return ;
              }
              int code=[x[@"code"]intValue];
              if (code==200) {
                  
                  self.user.isFriend=@(NO);
                  [[DBService defaultService].managedObjectContext save:nil];
                  
                  self.finish=@(YES);
                  
              }else{
                  [self netRequestFail:x];
              }
          }error:^(NSError *error) {
              [self netRequestError:error];
              self.busy=@(NO);
          }completed:^{
              self.busy=@(NO);
          }];

}
-(void)addBlackList{
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":self.user.itelNum};
    [[self.requestBuilder addToBlack:parameters] subscribeNext:^(NSDictionary *x) {
        
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[x[@"code"]intValue];
        if (code==200) {
            
            self.user.isBlack=@(YES);
            [[DBService defaultService].managedObjectContext save:nil];
            
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:x[@"msg"] message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
            
        }else{
            [self netRequestFail:x];
        }
    }error:^(NSError *error) {
        [self netRequestError:error];
        self.busy=@(NO);
    }completed:^{
        self.busy=@(NO);
    }];

}
@end
