//
//  PeopleViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-18.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "PeopleViewController.h"
#import "ItelAction.h"
#import "ItelBook.h"
#import "ContactCell.h"
#import "UserViewController.h"
#import "ItelBookManager.h"
#import "NXInputChecker.h"
#import "NSCAppDelegate.h"
#import "UIImageView+AFNetworking.h"
@interface PeopleViewController ()
@property (nonatomic,strong) ItelBook *contacts;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) ItelBook *searchResult;
@property (nonatomic,strong) UIPanGestureRecognizer *gestreRecognizer;

@end


@implementation PeopleViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
   	
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.searchResult=self.contacts;
    
}
-(ItelBook*)searchResult{
    if (_searchResult==nil) {
        _searchResult=[[ItelBook alloc]init];
        
    }
    return _searchResult;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"开始搜索:%@",searchBar.text );
    [self search:searchBar.text];
    [self.view endEditing:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar resignFirstResponder];
    searchBar.text=nil;
    [self endSearch];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (![NXInputChecker checkEmpty:searchText]) {
        [self endSearch];
    }
    else  [self search:searchText];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
     searchBar.text=@"";
    [self endSearch];
}
-(void)endSearch{
    self.searchResult=self.contacts;
    [self.tableVIew reloadData];
}
-(void)search:(NSString*)text{
    ItelBook *inNickName=[[ItelAction action] searchInFriendBookWithKeyPath:@"nickName" andSearch:text];
    ItelBook *inAlias=[[ItelAction action] searchInFriendBookWithKeyPath:@"remarkName" andSearch:text];
    ItelBook *inItels=[[ItelAction action] searchInFriendBookWithKeyPath:@"itelNum" andSearch:text];
    ItelBook *search=[[inNickName appendingByItelBook:inAlias] appendingByItelBook:inItels];
    self.searchResult=search;
    [self.tableVIew reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[self.searchResult getAllKeys] count];

}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (ContactCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"contactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([[self.searchResult getAllKeys] count]>indexPath.row) {
        ItelUser *user=[self.searchResult userAtIndex:indexPath.row];
        [cell setup];
        cell.user=user;
        //cell.imgPhoto.image=[UIImage imageNamed:@"头像.png"];
        [cell.imgPhoto setImageWithURL:[NSURL URLWithString:user.imageurl] placeholderImage:[UIImage imageNamed:@"头像.png"]];
        cell.lbItelNumber.text=user.itelNum;
        cell.lbNickName.text=user.remarkName;
        if ([user.remarkName isEqualToString:@""]) {
            cell.lbNickName.text=user.nickName;
          }
    }
   
    //config the cell
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ItelUser *user=[self.searchResult userAtIndex:indexPath.row];
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    UserViewController *userVC=[storyBoard instantiateViewControllerWithIdentifier:@"userView"];
    userVC.user=user;
    [self.navigationController pushViewController:userVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[ItelAction action] getItelFriendList:0];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshFriendListNotification:) name:@"getItelList" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAliasChanged:) name:@"resetAlias" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delNotification:) name:@"delItelUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellAction:) name:@"cellAction" object:nil];
   }
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableVIew reloadData];
}
-(void)cellAction:(NSNotification*)notification{
    NSString *action=[notification.userInfo objectForKey:@"action"];
    ItelUser *user=[notification.userInfo objectForKey:@"user"];
    
    if ([action isEqualToString:@"call"]) {
        [self callUser:user];
    }
    
}
-(void)callUser:(ItelUser*)user{
    NSCAppDelegate *appDelegate = (NSCAppDelegate*)[UIApplication sharedApplication].delegate;
    HostItelUser *host=[[ItelAction action] getHost];
    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENT_CALLING_VIEW_NOTIFICATION object:nil userInfo:@{
                                                                                                                       SESSION_INIT_REQ_FIELD_DEST_ACCOUNT_KEY:user.itelNum,
                                                                                                                       SESSION_INIT_REQ_FIELD_SRC_ACCOUNT_KEY:host.itelNum
                                                                                                                       }];
    [appDelegate.manager dial:user.itelNum];
}
-(void)delNotification:(NSNotification*)notification{
    NSDictionary *userInfo=notification.userInfo;
    BOOL isNormal=[[userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        self.contacts = [[ItelAction action]getFriendBook];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableVIew reloadData];
        });
        
    }
    
}
-(void)refreshFriendListNotification:(NSNotification*)notification{
    NSDictionary *userInfo=notification.userInfo;
    BOOL isNormal=[[userInfo objectForKey:@"isNormal"] boolValue];
    if (isNormal) {
        self.contacts = [[ItelAction action]getFriendBook];
        self.searchResult=self.contacts;
       
        [self.tableVIew reloadData];
    }
    else {
        NSLog(@"获得联系人列表失败");
    }
}
-(void)userAliasChanged:(NSNotification*)notification{
    ItelUser *user=(ItelUser*)notification.object;
    [self.contacts addUser:user forKey:user.itelNum];
    
}
@end
