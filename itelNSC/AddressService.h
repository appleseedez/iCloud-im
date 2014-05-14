//
//  AddressService.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"




@interface AddressService : BaseViewModel

@property (nonatomic) NSArray *addressList;
@property (nonatomic) NSNumber *isLoading;
+(AddressService*)defaultService;
-(void)loadAddressBook;
-(void)loadItels;
@end
