//
//  MainPageViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-9.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface MainPageViewModel : BaseViewModel
@property (nonatomic)  NSArray *adArray; //广告图片数组
@property (nonatomic)  NSNumber *loadingAD; //bool 正在加载广告
-(void)loadAdvertises;
@end
