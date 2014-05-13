//
//  SearchViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-12.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"
@class ItelUser;
@interface SearchViewModel : BaseViewModel
@property  (nonatomic) NSArray *searchResult;
-(void)startSearch:(NSString*)search;
-(void)addBlackList:(ItelUser*)user;
-(void)addNewFriend:(ItelUser*)user;
@end
