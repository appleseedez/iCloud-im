//
//  PeopleViewController.m
//  iCloudPhone
//
//  Created by nsc on 13-11-18.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "PeopleViewController.h"


#import "ContactCell.h"
#import "UserViewController.h"
#import "NXInputChecker.h"
#import "MaoAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "ContactViewModel.h"
#import "DBService.h"
#import "ItelUser+CRUD.h"
@interface PeopleViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) UIPanGestureRecognizer *gestreRecognizer;
@property (nonatomic,strong) NSString *searchText;
@property (nonatomic) NSPredicate* normalPredicate;
@property (nonatomic) NSPredicate* searchPredicate;
@property (nonatomic) NSDictionary *loginInfo;
@end


@implementation PeopleViewController


-(NSString*)searchText{
    if (_searchText==nil) {
         _searchText=@"";
    }
    return _searchText;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y<=0) {
        if (![self.searchBar isFirstResponder]) {
            [self.searchBar becomeFirstResponder];
        }
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupFetchViewController];

    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginInfo=((MaoAppDelegate*)[UIApplication sharedApplication].delegate).loginInfo;
    self.contactViewModel=[[ContactViewModel alloc]init];
    self.navigationController.delegate=self;
    self.searchBar.delegate = self;
   
    [(UIScrollView*)self.tableView setContentOffset:CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y+54)];
   	  [self.contactViewModel refreshFriendList];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController!=self) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"1"}];
    }
    
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   
    [self search:searchBar.text];
    [self.view endEditing:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar{
    [searchBar resignFirstResponder];
    searchBar.text=@"";
    //取消的时候， 返回到原始的搜索条件
    [self.fetchedResultsController.fetchRequest setPredicate:self.normalPredicate];
    [self.fetchedResultsController performFetch:nil ];
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
//    if (![NXInputChecker checkEmpty:searchText]) {
//    }
//    else  self.searchText=searchText;
    if (![NXInputChecker checkEmpty:searchText]) {
       [self.fetchedResultsController.fetchRequest setPredicate:self.normalPredicate];
    }else{
        self.searchPredicate= [NSCompoundPredicate orPredicateWithSubpredicates:@[
                                                                                  [NSPredicate predicateWithFormat:@"remarkName contains[cd] %@",searchText],
                                                                                  [NSPredicate predicateWithFormat:@"nickName contains[cd] %@",searchText],
                                                                                  [NSPredicate predicateWithFormat:@"itelNum contains %@",searchText]
                                                                                  
                                                                                  ]];
        [self.fetchedResultsController.fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:@[self.searchPredicate,self.normalPredicate]]];
    }

    

    [self.fetchedResultsController performFetch:nil];
    [self.tableView reloadData];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y>=10) {
         [self.view endEditing:YES];
    }
   
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}
-(void)search:(NSString*)text{
    
}

- (void) setupFetchViewController{
    if ([DBService defaultService].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickName" ascending:NO selector:nil]];
        
        self.normalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                    [NSPredicate predicateWithFormat:@"host = %@",[self.loginInfo objectForKey:@"itel"]]                                                                                    ,
                                                                                    [NSPredicate predicateWithFormat:@"isFriend = YES"]
                                                                                    ]];
        request.predicate = self.normalPredicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[DBService defaultService].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (ContactCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *CellIdentifier = @"contactCell";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    ItelUser *user=[self.fetchedResultsController objectAtIndexPath:indexPath];
        [cell setup];
        cell.user=user;
        //cell.imgPhoto.image=[UIImage imageNamed:@"头像.png"];
        [cell.imgPhoto setImageWithURL:[NSURL URLWithString:user.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
        cell.lbItelNumber.text=user.itelNum;
        cell.lbNickName.text=user.remarkName;
        if ([user.remarkName isEqualToString:@""]) {
            cell.lbNickName.text=user.nickName;
          }
    
    
   
    //config the cell
    return cell;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ItelUser *user=[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"Contact" bundle:nil];
    UserViewController *userVC=[storyBoard instantiateViewControllerWithIdentifier:@"userView"];
    userVC.user=user;
    [self.view endEditing:YES];
    [self.navigationController pushViewController:userVC animated:YES];
}



-(void)cellAction:(NSNotification*)notification{
    NSString *action=[notification.userInfo objectForKey:@"action"];
    ItelUser *user=[notification.userInfo objectForKey:@"user"];
    
    if ([action isEqualToString:@"call"]) {
        [self callUser:user];
    }
    
}
-(void)callUser:(ItelUser*)user{
}



@end
