//
//  PeopleViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-18.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCoreDataTableViewController.h"
@interface PeopleViewController : BaseCoreDataTableViewController <UISearchBarDelegate,UIScrollViewDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableVIew;

@end
