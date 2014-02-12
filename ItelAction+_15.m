//
//  ItelAction+_15.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "ItelAction+_15.h"
#import "ItelIntentImp.h"
@interface ItelAction ()
-(void) NotifyForNormalResponse:(NSString*)name intent:(id<ItelIntent>)intent;

@end

@implementation ItelAction (_15)
-(void)search115:(NSString*)search{
    NSDictionary *parameters=@{@"itel": search,@"start":@(0),@"limit":@(2048)};
    [self.itelNetRequestActionDelegate search115:parameters];
    
}
-(void)search115Response:(NSArray*)data{
//    NSMutableArray *hundledData=[data mutableCopy];
//    for(NSDictionary *dic in data){
//        NSMutableDictionary *hundledDic=[dic mutableCopy];
//        for (NSString *p in [dic allKeys]) {
//            if ([p isEqual:[NSNull null]]) {
//                [hundledDic setObject:@"" forKey:p];
//            }
//        }
//        [hundledData setObject:hundledDic atIndexedSubscript:[data indexOfObject:dic]];
//    }
//    
    NSLog(@"%@",data);
    id <ItelIntent> intent;
    if ([data count]) {
        intent=[ItelIntentImp newIntent:intentTypeProcessStart ];
         NSDictionary *userInfo=@{@"list":data};
        intent.userInfo=userInfo;
    }
    else{
        intent=[ItelIntentImp newIntent:intentTypeMessage];
        intent.userInfo=@{@"title":@"没有找到符合要求的用户",@"message":@"该号码未注册，没有企业相关信息"};
    }
    [self NotifyForNormalResponse:@"115search" intent:intent];
}
@end
