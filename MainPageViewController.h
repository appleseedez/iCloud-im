//
//  MainPageViewController.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainPageViewModel;
@interface MainPageViewController : UIViewController <UIScrollViewDelegate>
@property  (nonatomic,strong) MainPageViewModel *viewModel;
@end
