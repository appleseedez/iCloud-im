//
//  NewFriendListViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-12-3.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "NewFriendListViewController.h"
#import "StrangerViewController.h"
#import "StrangerCell.h"
#import "DBService.h"
#import "NXInputChecker.h"
#import "UIImageView+AFNetworking.h"
#import "ItelUser+CRUD.h"
#import "SearchViewModel.h"

@interface NewFriendListViewController ()

@end

@implementation NewFriendListViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    __weak id weakSelf=self;
    [RACObserve(self, searchViewModel.searchResult) subscribeNext:^(NSArray *x) {
      __strong  NewFriendListViewController *strongSelf=weakSelf;
        if ([x count]) {
            strongSelf.searchResult=x;
            [strongSelf.tableView reloadData];
            
        }
    }];
}
#pragma mark -tableView 代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.searchResult count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"查询结果";
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (StrangerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"StrangerCell";
    StrangerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   
    
    NSDictionary *dic=[self.searchResult objectAtIndex:indexPath.row];
    //cell.imgPhoto.image=[UIImage imageNamed:@"头像.png"];
    ItelUser *user=[ItelUser userWithDictionary:dic inContext:[DBService defaultService].managedObjectContext];
    [cell.imgPhoto setImageWithURL:[NSURL URLWithString:user.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    cell.lbItelNumber.text=user.itelNum;
    
    cell.lbNickName.text=user.nickName;
    
    
    
    
    //config the cell
    return cell;
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:NO];
    if ([NXInputChecker checkEmpty:self.searchText]) {
       
    }
   
}


-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
  
    StrangerViewController *strangerVC=[self.storyboard instantiateViewControllerWithIdentifier:@"stragerView"];
    NSDictionary *dic=[self.searchResult objectAtIndex:indexPath.row];
  
    ItelUser *user=[ItelUser userWithDictionary:dic inContext:[DBService defaultService].managedObjectContext];
    strangerVC.user=user;
    strangerVC.searchViewModel=self.searchViewModel;
    [self.navigationController pushViewController:strangerVC animated:YES];
}
-(void)dealloc{
    NSLog(@"NewFriendListVC被销毁");
}


@end
