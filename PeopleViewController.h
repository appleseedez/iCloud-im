//
//  PeopleViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-18.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
@class ContactViewModel;
@interface PeopleViewController : CoreDataTableViewController <UISearchBarDelegate,UIScrollViewDelegate,UINavigationControllerDelegate,UITableViewDelegate>

@property (nonatomic) ContactViewModel *contactViewModel;
@end