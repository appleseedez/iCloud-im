//
//  MoreBlackLisetViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"

@interface MoreBlackLisetViewModel : BaseViewModel
@property  (nonatomic) NSArray *blackList;
-(void)loadBlackList;
-(void)removeFromBlackList:(NSString *)itel;
@end
