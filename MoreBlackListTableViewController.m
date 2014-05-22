//
//  MoreBlackListTableViewController.m
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreBlackListTableViewController.h"
#import "MoreBlackLisetViewModel.h"
#import <MBProgressHUD.h>
#import "AppService.h"
#import "DBService.h"
#import "MaoAppDelegate.h"
#import "MoreBlackListCell.h"
#import "ItelUser+CRUD.h"
#import <UIImageView+AFNetworking.h>
@interface MoreBlackListTableViewController ()
@property (nonatomic,weak) NSDictionary *loginInfo;
@end

@implementation MoreBlackListTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.blackViewModel=[[MoreBlackLisetViewModel alloc]init];
    __weak id weakSelf=self;
    
    [RACObserve(self, blackViewModel.busy) subscribeNext:^(NSNumber *x) {
        __strong MoreBlackListTableViewController *strongSelf=weakSelf;
        BOOL busy= [x boolValue];
        if (busy) {
            MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
            hud.labelText=@"请稍后";
        }else{
            [MBProgressHUD hideAllHUDsForView:strongSelf.view animated:YES];
        }
    }];
    if (![[AppService defaultService].blackLoaded boolValue]) {
        [self.blackViewModel loadBlackList];
    }
    [self setupFetchViewController];
}
- (void) setupFetchViewController{
    if ([DBService defaultService].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ItelUser"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"nickName" ascending:NO selector:nil]];
        self.loginInfo=((MaoAppDelegate*)[UIApplication sharedApplication].delegate).loginInfo;
        
        NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[
                                                                                    [NSPredicate predicateWithFormat:@"host = %@",[self.loginInfo objectForKey:@"itel"]]                                                                                    ,
                                                                                    [NSPredicate predicateWithFormat:@"isBlack = YES"]
                                                                                    ]];
        request.predicate = predicate;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[DBService defaultService].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"moreBlack";
    MoreBlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    ItelUser *user=[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.imgHeader setImageWithURL:[NSURL URLWithString:user.imageurl] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    cell.lbItel.text=user.itelNum;
    cell.blNickname.text=user.nickName;
    cell.user=user;
    cell.blackViewModel=self.blackViewModel;
    
    return cell;
}
@end
