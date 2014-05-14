//
//  PassWayViewController.h
//  RegisterAndLogin
//
//  Created by nsc on 14-5-6.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PassViewModel;
@interface PassWayViewController : UITableViewController
@property (nonatomic,weak) PassViewModel *passViewModel;
@end
