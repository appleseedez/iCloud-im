//
//  MoreBlackLisetViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreBlackLisetViewModel.h"
#import "HTTPRequestBuilder+More.h"
#import "ItelUser+CRUD.h"
#import "DBService.h"
#import "AppService.h"
@implementation MoreBlackLisetViewModel


-(void)loadBlackList{
    self.busy=@(YES);
    NSDictionary *parameters = @{@"keyWord":[self hostUserID] ,@"start":@(0),@"limit":[NSNumber numberWithInteger:2030]};
    [[self.requestBuilder loadBlackList:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[[x objectForKey:@"code"]intValue];
        if (code==200) {
            NSArray *list=[[x objectForKey:@"data"] objectForKey:@"list"];
            NSMutableArray *bList=[[NSMutableArray alloc]init];
            if ([list count]) {
                NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
                for (NSDictionary *d in list) {
                    ItelUser *user=[ItelUser userWithDictionary:d inContext:context];
                    user.isBlack=@(YES);
                    [bList addObject:user];
                }
                [context save:nil];
                [AppService defaultService].blackLoaded=@(YES);
            }
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
-(void)removeFromBlackList:(NSString *)itel{
    self.busy=@(YES);
     NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":itel};
    [[self.requestBuilder removeFromBlackList:parameters] subscribeNext:^(NSDictionary *x) {
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[[x objectForKey:@"code"] intValue];
        if (code==200) {
            NSManagedObjectContext *context=[DBService defaultService].managedObjectContext;
            ItelUser *user;
            
            NSFetchRequest* getOneUser = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
            getOneUser.predicate = [NSPredicate predicateWithFormat:@"itelNum = %@",[[x objectForKey:@"data"] valueForKey:@"itel" ]];
            NSError *error=nil;
            NSArray* match = [context executeFetchRequest:getOneUser error:&error];
            if ([match count]) {
                user =(ItelUser*)match[0];
                user.isBlack=@(NO);
            }
            
        }else{
            [self netRequestFail:x];
        }
        
        
    } error:^(NSError *error) {
        self.busy=@(NO);
        [self netRequestError:error];
    } completed:^{
        self.busy=@(NO);
    }];
}
@end
