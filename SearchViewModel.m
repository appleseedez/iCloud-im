//
//  SearchViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-12.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "SearchViewModel.h"
#import "HTTPRequestBuilder+contact.h"
#import "ItelUser+CRUD.h"
#import "DBService.h"
@implementation SearchViewModel
-(void)startSearch:(NSString*)search{
    self.busy=@(YES);
    NSDictionary *Parameters=@{@"start":@(0),
                               @"limit":@(1500),
                               @"keyWord":search,
                              
                               @"hostUserId":[self hostUserID]
                               };
    __weak SearchViewModel *weakSelf=self;
    [[self.requestBuilder searchStranger:Parameters] subscribeNext:^(NSDictionary *x) {
        int code=[x[@"code"] intValue];
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        if (code==200) {
           __weak NSArray *arr=x[@"data"][@"list"];
            NSMutableArray *marr=[NSMutableArray new];
            NSManagedObjectContext *contex=[DBService defaultService].managedObjectContext;
            for (NSDictionary *dic in arr) {
                ItelUser *user=[ItelUser userWithDictionary:dic inContext:contex];
                if (![user.isFriend boolValue]&&![user.itelNum isEqualToString:[weakSelf hostItel]]) {
                    [marr addObject:dic];
                }
            }
            weakSelf.searchResult=marr;
            if (![weakSelf.searchResult count]) {
                [[[UIAlertView alloc]initWithTitle:@"没有搜索结果" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            }
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
-(void)addBlackList:(ItelUser*)user
{
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":user.itelNum};
    [[self.requestBuilder addToBlack:parameters] subscribeNext:^(NSDictionary *x) {
        
        if (![x isKindOfClass:[NSDictionary class]]) {
            [self responseError:x];
            return ;
        }
        int code=[x[@"code"]intValue];
        if (code==200) {
            
            user.isBlack=@(YES);
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
-(void)addNewFriend:(ItelUser*)user{
    self.busy=@(YES);
    NSDictionary *parameters = @{@"userId":[self hostUserID] ,@"hostItel":[self hostItel],@"targetItel":user.itelNum};
    __block ItelUser *blockUser=user;
      
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
- (void)dealloc
{
    NSLog(@"searchViewModel被成功销毁");
}
@end
