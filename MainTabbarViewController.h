//
//  MainTabbarViewController.h
//  itelNSC
//
//  Created by nsc on 14-5-8.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CustomBarItem;
@class RootViewModel;
@interface MainTabbarViewController : UITabBarController <NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet CustomBarItem *dialItem;
@property (weak, nonatomic) IBOutlet CustomBarItem *contactItem;
@property (weak, nonatomic) IBOutlet CustomBarItem *mainItem;
@property (weak, nonatomic) IBOutlet CustomBarItem *moreItem;
@property (weak, nonatomic) IBOutlet CustomBarItem *messageItem;
@property (weak,nonatomic)  RootViewModel *viewModel;
@property (nonatomic)  NSNumber *selectIndex;
-(void)chooseSelectedView:(NSInteger)index;
-(void)presentDialPan;
@end
