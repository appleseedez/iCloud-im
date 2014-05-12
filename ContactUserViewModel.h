//
//  ContactUserViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-12.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"
#import "ItelUser+CRUD.h"
@interface ContactUserViewModel : BaseViewModel
@property (nonatomic) ItelUser *user;

@property (nonatomic) NSNumber *finish; //bool 删除好友 结束
-(void)editAlias:(NSString*)newAlias;
-(void)delUser;
-(void)addBlackList;
@end
