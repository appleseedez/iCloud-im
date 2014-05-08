//
//  DialingViewController.h
//  DIalViewSence
//
//  Created by nsc on 14-4-23.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DialViewModel.h"
typedef NS_ENUM(NSInteger, suggestViewType) {
    suggestViewTypeResult,
    suggestViewTypeAdd,
    suggestViewTypeNone,
    suggestViewTypeEmpty,
    
};

@interface DialingViewController : UIViewController
@property (nonatomic) DialViewModel *viewModel;
@end
