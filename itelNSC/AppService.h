//
//  AppService.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

NS_ENUM(NSInteger, rootViewType){
     rootViewTypeLogin,
     rootViewTypeMain
};

@interface AppService : BaseViewModel
+(instancetype)defaultService;


@property (nonatomic) NSNumber *rootViewType;
-(void)logout;
@end
