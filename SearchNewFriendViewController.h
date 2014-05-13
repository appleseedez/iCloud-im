//
//  SearchNewFriendViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SearchViewModel;
@interface SearchNewFriendViewController : UIViewController<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic)SearchViewModel *searchViewModel;
@end
