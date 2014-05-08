//
//  AppService.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger, rootViewType){
     rootViewTypeLogin,
     rootViewTypeMain
};

@interface AppService : NSObject
+(instancetype)defaultService;
@property (nonatomic) NSNumber *rootViewType;
@end
