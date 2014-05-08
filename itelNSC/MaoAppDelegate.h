//
//  MaoAppDelegate.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaoAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic)  NSString *UUID;
@property (nonatomic)  NSDictionary *loginInfo;
@property (nonatomic) NSArray *backUsers;
@end
