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
#import "NXInputChecker.h"
#import "NSCAppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "IMCoreDataManager.h"
#import "ConstantHeader.h"

@interface PeopleViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic,strong) UIPanGestureRecognizer *gestreRecognizer;
@property (nonatomic,strong) NSString *searchText;
@property (nonatomic) NSPredicate* normalPredicate;
@property (nonatomic) NSPredicate* searchPredicate;
@end


@implementation PeopleViewController


-(NSString*)searchText{
    if (_searchText==nil) {
         _searchText=@"";
    }
    return _searchText;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.delegate=self;
    self.searchBar.delegate = self;
   	
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
    searchBar.text=BLANK_STRING;
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
    [self.view endEditing:YES];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}
-(void)search:(NSString*)text{
    
}

- (void) setupFetchViewController{
    if ([IMCoreDataManager defaulManager].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickName" ascending:NO selector:nil]];
        
        self.normalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                    [NSPredicate predicateWithFormat:@"host.itelNum = %@",[[ItelAction action] getHost].itelNum                                                                                     ],
                                                                                    [NSPredicate predicateWithFormat:@"isFriend = YES"]
                                                                                    ]];
        request.predicate = self.normalPredicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext
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
        [cell.imgPhoto setImageWithURL:[NSURL URLWithString:user.imageurl]];
        cell.lbItelNumber.text=user.itelNum;
        cell.lbNickName.text=user.remarkName;
        if ([user.remarkName isEqualToString:@""]) {
            cell.lbNickName.text=user.nickName;
          }
    
    
   
    //config the cell
    return cell;
    
}
-(float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    ItelUser *user=[self.fetchedResultsController objectAtIndexPath:indexPath];
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"iCloudPhone" bundle:nil];
    UserViewController *userVC=[storyBoard instantiateViewControllerWithIdentifier:@"userView"];
    userVC.user=user;
    [self.view endEditing:YES];
    [self.navigationController pushViewController:userVC animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupFetchViewController];
     [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"0"}];
    [[ItelAction action] getItelFriendList:0];
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



@end
