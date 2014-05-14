//
//  MainPageViewModel.m
//  itelNSC
//
//  Created by nsc on 14-5-9.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MainPageViewModel.h"
#import "HTTPRequestBuilder+mainPage.h"
@implementation MainPageViewModel
-(void)loadAdvertises{
    self.loadingAD=@(YES);
    
    RACSignal *signal= [self.requestBuilder loadADImages];
    
      [signal subscribeNext:^(NSDictionary *x) {
          if (![x isKindOfClass:[NSDictionary class]]) {
              [self responseError:x];
              return ;
          }
          int code=[[x objectForKey:@"code"]intValue];
          if (code==200) {
              self.adArray=[x objectForKey:@"data"];
          }
      }error:^(NSError *error) {
          self.loadingAD=@(NO);
      }completed:^{
          self.loadingAD=@(NO);
      }];
}
-(void)dealloc{
    NSLog(@"mainPageViewModel被销毁");
}

@end
