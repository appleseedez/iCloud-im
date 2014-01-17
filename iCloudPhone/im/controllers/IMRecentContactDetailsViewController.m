//
//  IMRecentContactDetailsViewController.m
//  iCloudPhone
//
//  Created by Pharaoh on 12/30/13.
//  Copyright (c) 2013 NX. All rights reserved.
//

#import "IMRecentContactDetailsViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "IMCoreDataManager.h"
#import "ItelAction.h"
static NSString* kOperationStatusNormal = @"isNormal";
static NSString* kOperationReason = @"reason";
@interface IMRecentContactDetailsViewController ()

@end

@implementation IMRecentContactDetailsViewController

- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
        [self setup];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self tearDown];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - life
- (void) setup{
    [self.avatarView setImageWithURL:[NSURL URLWithString:self.currentRecent.peerAvatar] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    self.nameLabel.text =self.currentRecent.peerRealName;
    self.nickLabel.text = self.currentRecent.peerNick;
    self.numberLabel.text = self.currentRecent.peerNumber;
    [self setupFetchViewController];
}

- (void) tearDown{
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

#pragma mark - Table view data source



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Contact Cell";
    static NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    Recent* record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    UIImageView* statusView = (UIImageView*)[cell.contentView viewWithTag:1];
    UILabel* timeStampLabel = (UILabel*) [cell.contentView viewWithTag:2];
    UILabel* durationLabel = (UILabel*) [cell.contentView viewWithTag:3];
    NSString* statusImage = [NSString stringWithFormat:@"%@_ico",record.status];
    [statusView setImage:[UIImage imageNamed:statusImage]];
    timeStampLabel.text = [timeFormatter stringFromDate:record.createDate];
    durationLabel.text = [IMUtils secondsToTimeFormat:[record.duration integerValue]];
    return cell;
}

- (void) setupFetchViewController{
    if ([IMCoreDataManager defaulManager].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO selector:nil]];
        request.predicate = [NSPredicate predicateWithFormat:@"peerNumber = %@ and hostUserNumber = %@", self.currentRecent.peerNumber,[self.manager myAccount]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void) delteRecentsOfMyOwn{
    NSError* error = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
    request.sortDescriptors = @[];
    request.predicate = [NSPredicate predicateWithFormat:@"peerNumber = %@ and hostUserNumber = %@", self.currentRecent.peerNumber,[self.manager myAccount]];
    NSArray* results =  [[[IMCoreDataManager defaulManager] managedObjectContext] executeFetchRequest:request error:&error];
    if (!error) {
        for (Recent* r in results) {
            [r delete];
        }
        [[IMCoreDataManager defaulManager] saveContext];
    }else{
        [NSException exceptionWithName:@"database error" reason:@"core data 查询失败" userInfo:nil];
    }
}
#pragma mark - actionSheet delegate
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    actionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.numberOfButtons == 4) {
        // 陌生人
        //点击加好友
        if (buttonIndex == 0) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inviteItelUserResultHandel:) name:ADD_FIRIEND_NOTIFICATION object:nil];
            
            [[ItelAction action] inviteItelUserFriend:self.currentRecent.peerNumber];
        
        }else if (buttonIndex == 1){ //点击加入黑名单
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBlackListResultHandel:) name:ADD_TO_BLACK_LIST_NOTIFICATION object:nil];
            [[ItelAction action] addItelUserBlack:self.currentRecent.peerNumber];
        }
    }else{
       //好友
        //点击加入黑名单
        if (buttonIndex == 0) {
            if ([[ItelAction action] userInBlackBook:self.currentRecent.peerNumber]) {
                //已经在黑名单了
               UIAlertView* alert =  [[UIAlertView alloc] initWithTitle:nil message:@"已经加入黑名单了" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil,nil];
                [alert show];
                return;
            }
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addBlackListResultHandel:) name:ADD_TO_BLACK_LIST_NOTIFICATION object:nil];
            [[ItelAction action] addItelUserBlack:self.currentRecent.peerNumber];
        }
    }
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        //删除记录
        [self delteRecentsOfMyOwn];
    }
    
}
//添加好友结果回调
- (void) inviteItelUserResultHandel:(NSNotification*) notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_FIRIEND_NOTIFICATION object:nil];
    UIAlertView* alert = nil;
    if ([[notify.userInfo valueForKey:kOperationStatusNormal] boolValue]) {
        alert =[ [UIAlertView alloc] initWithTitle:nil message:@"操作成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    }else{
        alert =[ [UIAlertView alloc] initWithTitle:nil message:[notify.userInfo valueForKey:kOperationReason] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
       
    }
    [alert show];
}
- (void) addBlackListResultHandel:(NSNotification*) notify{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ADD_TO_BLACK_LIST_NOTIFICATION object:nil];
    UIAlertView* alert = nil;
    if ([[notify.userInfo valueForKey:kOperationStatusNormal] boolValue]) {
         [[ItelAction action] getItelBlackList:0];
        alert =[ [UIAlertView alloc] initWithTitle:nil message:@"操作成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
       
    }else{
         alert =[ [UIAlertView alloc] initWithTitle:nil message:[notify.userInfo valueForKey:kOperationReason] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    }
    [alert show];
    
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    alertView.delegate = nil;
    alertView = nil;
}
- (IBAction)moreAction:(UIBarButtonItem *)sender {
    UIActionSheet* moreActionSheet = nil;
    if ([[ItelAction action] userInFriendBook:self.currentRecent.peerNumber]) {
        
        moreActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles: @"加入黑名单",@"删除记录",nil];
        
        [moreActionSheet setDestructiveButtonIndex:1];
    }else{
        moreActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"加为好友", @"加入黑名单",@"删除记录",nil];
        
        [moreActionSheet setDestructiveButtonIndex:2];
    }

    [moreActionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void)videoDial:(UIButton *)sender{
    [self.manager setIsVideoCall:YES];
    [self.manager dial:self.currentRecent.peerNumber];
}
- (void)voiceDial:(UIButton *)sender{
    [self.manager setIsVideoCall:NO];
    [self.manager dial:self.currentRecent.peerNumber];
}
@end
