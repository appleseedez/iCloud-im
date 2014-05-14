//
//  SearchNewFriendViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-16.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "SearchNewFriendViewController.h"
#import "NXInputChecker.h"
#import "SearchViewModel.h"
#import "StrangerCell.h"
#import "StrangerViewController.h"
#import "NewFriendListViewController.h"
@interface SearchNewFriendViewController ()
@end

@implementation SearchNewFriendViewController

//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.view endEditing:YES];
//}

#pragma mark -网络接口


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchViewModel=[[SearchViewModel alloc]init];
    __weak id weekSelf=self;
    //监听hud
    [RACObserve(self, searchViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong SearchNewFriendViewController *strongSelf=weekSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    
    //监听 搜索结果
    [RACObserve(self, searchViewModel.searchResult) subscribeNext:^(NSArray *x) {
        __strong SearchNewFriendViewController *strongSelf=weekSelf;
        if ([x count]) {
            [strongSelf pushNewFriendList:nil];
        }
        
    }];
	
}

-(void)pushNewFriendList:(NSString*)searchText{
   
    NewFriendListViewController *newList=[self.storyboard instantiateViewControllerWithIdentifier:@"newFriendList"];
    
    newList.searchViewModel=self.searchViewModel;
    [self.navigationController pushViewController:newList animated:YES];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
    NSString *search=searchBar.text;
    [self.searchViewModel startSearch:search];
    
   
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}
-(void)dealloc{
    NSLog(@"searchNewFriendVC被销毁");
}
@end
