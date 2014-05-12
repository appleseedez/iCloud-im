//
//  RootViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "RootViewModel.h"

@implementation RootViewModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        
          [[NSNotificationCenter defaultCenter]addObserverForName:@"showTabbar" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
              self.showTabbar=@(YES);
          }];
        [[NSNotificationCenter defaultCenter]addObserverForName:@"hideTabbar" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            self.showTabbar=@(NO);
        }];
        self.showTabbar=@(YES);
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
