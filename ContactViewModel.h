//
//  ContactViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-10.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface ContactViewModel : BaseViewModel
-(void)addNewFriend:(NSString*)itel;
-(void)refreshFriendList;
@end
