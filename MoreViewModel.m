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
        
        [RACObserve(self, appDelegate.loginInfo) subscribeNext:^(NSDictionary *x) {
            if (x) {
                
            
            self.itel=x[@"itel"];
            self.qq=x[@"qq_num"];
            self.area=x[@"area_code"];
            self.email=x[@"mail"];
            self.nickname=x[@"nick_name"];
            self.birthday=x[@"birthday"];
            self.phone=x[@"phone"];
            self.imgUrl=x[@"photo_file_name"];
            }
        }];
    }
    return self;
}
@end
