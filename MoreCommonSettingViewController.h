//
//  MoreCommonSettingViewController.h
//  itelNSC
//
//  Created by nsc on 14-5-20.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MoreViewModel;
@interface MoreCommonSettingViewController : UITableViewController
@property (nonatomic,weak) MoreViewModel *moreViewModel;
@end