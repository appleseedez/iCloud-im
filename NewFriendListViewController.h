//
//  NewFriendListViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-12-3.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchViewModel;
@interface NewFriendListViewController : UITableViewController
@property (nonatomic,strong) NSArray *searchResult;
@property (nonatomic,strong) NSString *searchText;
@property (nonatomic)       SearchViewModel *searchViewModel;
@end
