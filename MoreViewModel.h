//
//  MoreViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"
#import "MaoAppDelegate.h"
@interface MoreViewModel : BaseViewModel
@property (nonatomic) NSString *imgUrl;
@property (nonatomic) NSString *nickname;
@property (nonatomic) NSString *itel;
@property (nonatomic) NSString *email;
@property (nonatomic) NSString *qq;
@property (nonatomic) NSString *sign;
@property (nonatomic) NSString *area;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *sex;
@property (nonatomic) NSString *birthday;
@property (nonatomic,weak) MaoAppDelegate *appDelegate;
@end
