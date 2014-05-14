//
//  MoreViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreViewModel.h"

@implementation MoreViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.appDelegate=(MaoAppDelegate*)[UIApplication sharedApplication].delegate;
        __weak id weekSelf=self;
        [RACObserve(self, appDelegate.loginInfo) subscribeNext:^(NSDictionary *x) {
            __strong MoreViewModel *strongSelf=weekSelf;
            if (x) {
                
            
            strongSelf.itel=x[@"itel"];
            strongSelf.qq=x[@"qq_num"];
            strongSelf.area=x[@"area_code"];
            strongSelf.email=x[@"mail"];
            strongSelf.nickname=x[@"nick_name"];
            strongSelf.birthday=x[@"birthday"];
            strongSelf.phone=x[@"phone"];
            strongSelf.imgUrl=x[@"photo_file_name"];
            }
        }];
    }
    return self;
}
- (void)dealloc
{
    NSLog(@"moreViewModel成功被销毁");
}
@end
