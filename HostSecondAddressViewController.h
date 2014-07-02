//
//  HostSecondAddressViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-1-14.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Area.h"
@class MoreViewModel;
@interface HostSecondAddressViewController : CoreDataTableViewController
@property (strong , nonatomic) Area *parentArea;
@property (nonatomic,weak) MoreViewModel *moreViewModel;
@end
