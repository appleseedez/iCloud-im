//
//  IMRecentContactListViewController.m
//  im
//
//  Created by Pharaoh on 13-12-6.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMRecentContactListViewController.h"
#import "IMRootTabBarViewController.h"
#import "IMDailViewController.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "FMDatabase.h"
#import "IMRecentContactItem.h"
#import "IMManager.h"
#import "IMCoreDataManager.h"
#import "Recent.h"
#import "Recent+CRUD.h"
#import "IMRecentContactDetailsViewController.h"
#import "NSCAppDelegate.h"
@interface IMRecentContactListViewController ()
@property(nonatomic,weak) id<IMManager> manager;
@end

@implementation IMRecentContactListViewController
- (id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (viewController!=self) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"1"}];
    }
    
}
- (void)awakeFromNib{
    [super awakeFromNib];
    [self registerNotifications];
    NSLog(@"床上");

}
- (id<IMManager>)manager{
    if (_manager == nil) {
        NSCAppDelegate* app = (NSCAppDelegate*) [UIApplication sharedApplication].delegate;
        NSAssert(app.manager, @"没有immanager");
        _manager = (id<IMManager>) app.manager;
    }
    return _manager;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"hideTab" object:nil userInfo:@{@"hidden":@"0"}];
    [self setup];
    [self setupFetchViewController];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self tearDown];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
#if OTHER_MESSAGE
     NSLog(@"tableView的viewDidLoad方法被调用");
#endif
    self.navigationController.delegate=self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
#if OTHER_MESSAGE
    NSLog(@"IMRecentContactListViewController被销毁了");
#endif
}
#pragma mark - private
//由通知回调
- (void) setup{

//    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
//    IMDailViewController* dialViewController = (IMDailViewController*) [sb instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
//    dialViewController.manager = self.manager;
//    [self presentViewController:dialViewController animated:YES completion:nil];
    
}

- (void) presentPan{

    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    IMDailViewController* dialViewController = (IMDailViewController*) [sb instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
    dialViewController.manager = self.manager;
    [self presentViewController:dialViewController animated:YES completion:nil];
}

- (void) tearDown {
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}


- (void) setupFetchViewController{
    if ([IMCoreDataManager defaulManager].managedObjectContext) {
// 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO selector:nil]];
        request.predicate = [NSPredicate predicateWithFormat:@"hostUserNumber = %@",[self.manager myAccount]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext
                                                                              sectionNameKeyPath:@"sectionIdentifier"
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

- (void) loadData{
   //当加载数据后, 根据数据的分组情况,生成数个实现了NSxxxinfo接口的对象
    
}
-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentPan) name:PRESENT_DIAL_VIEW_NOTIFICATION object:nil];
}

#pragma mark - Table view data source


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id <NSFetchedResultsSectionInfo> theSection = [[self.fetchedResultsController sections] objectAtIndex:section];

    static NSDateFormatter *formatter = nil;
    
    if (!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
       
//        NSString *formatTemplate = [NSDateFormatter dateFormatFromTemplate:@"YYYY MM-dd" options:0 locale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"YYYY-MM-dd"];
    }
   // 把每个section的标题转换为真正的日期显示
    NSInteger numericSection = [[theSection name] integerValue];
    NSInteger year = numericSection / 1000000;
	NSInteger month =(numericSection -  (year * 1000000))/1000;
	NSInteger day = numericSection - (year * 1000000) - (month * 1000);
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
	NSString *titleString = [formatter stringFromDate:date];
	return titleString;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Call Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    Recent* record = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
        UIImageView* avatarView = (UIImageView*)[cell.contentView viewWithTag:1];
    UILabel* nameLabel = (UILabel*) [cell.contentView viewWithTag:2];
    UILabel* numberLabel = (UILabel*) [cell.contentView viewWithTag:3];
    UIImageView* statusView = (UIImageView*) [cell.contentView viewWithTag:4];
    [avatarView setImageWithURL:[NSURL URLWithString:record.peerAvatar] placeholderImage:[UIImage imageNamed:@"standedHeader"]];
    [nameLabel setText:record.peerNick];
    [numberLabel setText:record.peerNumber];
    [statusView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_ico",record.status]]];
 
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Recent* recent = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectContext* currentContext = recent.managedObjectContext;
        if (currentContext) {
            [recent delete];
            [[IMCoreDataManager defaulManager] saveContext:currentContext];
        }


    }
}

#pragma mark - segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
//    
//    if ([segue.identifier isEqualToString:@"Recent Detail"]) {
        Recent* selectedRecent = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell *) sender]];
        [(IMRecentContactDetailsViewController*)segue.destinationViewController setCurrentRecent:selectedRecent];
        [(IMRecentContactDetailsViewController*)segue.destinationViewController setManager:self.manager];
    
//    }
}

#pragma mark - actionSheet delegate
- (void)actionSheetCancel:(UIActionSheet *)actionSheet{
    actionSheet = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [Recent deleteAllWithAccount:[self.manager myAccount]];

    }
}
- (IBAction)deleteAllRecents:(UIBarButtonItem*)sender{
    if ([[self.fetchedResultsController sections] count]) {
        UIActionSheet* confirmSheet = [[UIActionSheet alloc] initWithTitle:@"将要删除全部通话记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"全部删除" otherButtonTitles:nil, nil];
        [confirmSheet showFromTabBar:self.tabBarController.tabBar];
        
    }
    
}
@end
