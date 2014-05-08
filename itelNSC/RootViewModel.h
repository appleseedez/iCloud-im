//
//  RootViewModel.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "BaseViewModel.h"
@class DialViewModel;
@interface RootViewModel : BaseViewModel
@property (nonatomic) NSNumber *showSessinView;
@property (nonatomic) NSNumber *dialViewType;
@property (nonatomic) DialViewModel *dialViewModel;
@end
