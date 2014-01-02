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
@interface IMRecentContactListViewController ()
@property id<IMManager> manager;
@property(nonatomic,strong) NSArray* testRecords;
@property(nonatomic,strong) NSMutableArray* recentContactsDataSource;
@property(nonatomic) NSDateFormatter* sectionTitleFormatter;
@end

@implementation IMRecentContactListViewController
- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.sectionTitleFormatter = [[NSDateFormatter alloc] init];
    [self.sectionTitleFormatter setDateFormat:@"yyyy-MM-dd"];
    [self registerNotifications];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
#if OTHER_MESSAGE
     NSLog(@"tableView的viewDidLoad方法被调用");
#endif
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
- (void) setup{
    IMRootTabBarViewController* root =(IMRootTabBarViewController*)self.tabBarController;
    self.manager = root.manager;
    UIStoryboard* sb = [UIStoryboard storyboardWithName:MAIN_STORY_BOARD bundle:nil];
    IMDailViewController* dialViewController = (IMDailViewController*) [sb instantiateViewControllerWithIdentifier:DIAL_PAN_VIEW_CONTROLLER_ID];
    dialViewController.manager = self.manager;
    [self presentViewController:dialViewController animated:YES completion:nil];
    
}
/**
 *  从sqlite 加载最近联系人信息
 */
- (void) loadData{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"Recents" ofType:@"db"];
    FMDatabase* db = [FMDatabase databaseWithPath:path];
    [db setDateFormat:self.sectionTitleFormatter];
    if ( [db open]) {
        FMResultSet* recentContactsList = [db executeQuery:@"SELECT * FROM recents ORDER BY create_date DESC"];
        NSString* title = BLANK_STRING;
        if (!self.recentContactsDataSource) {
            self.recentContactsDataSource = [[NSMutableArray alloc] init];
        }
        NSMutableDictionary* itemSection;
        while ([recentContactsList next]) {
            NSString* peerNumber = [recentContactsList stringForColumn:@"peer_number"];
            NSString* peerRealName = [recentContactsList stringForColumn:@"peer_real_name"];
            NSString* peerAvatar = [recentContactsList stringForColumn:@"peer_avatar"];
            NSString* peerNick = [recentContactsList stringForColumn:@"peer_nick"];
            NSDate* createDate = [recentContactsList dateForColumn:@"create_date"];
            NSString* createDateStr =[self.sectionTitleFormatter stringFromDate:createDate] ;
            NSNumber* duration = @([recentContactsList longForColumn:@"duration"]);
            NSString* status = [recentContactsList stringForColumn:@"status"];
            IMRecentContactItem* item = [IMRecentContactItem new];
            item.peerNick = peerNick;
            item.peerNumber = peerNumber;
            item.peerRealName = peerRealName;
            item.peerAvatar = peerAvatar;
            item.createDate = createDate;
            item.createDateStr = createDateStr;
            item.duration = duration;
            item.status = status;
            // 如果用create_date作为section分割的依据
            if (![title isEqualToString:item.createDateStr]) {
                title = item.createDateStr;
                itemSection = [NSMutableDictionary new];
                [itemSection addEntriesFromDictionary:@{@"time":title}];
                [itemSection addEntriesFromDictionary:@{@"datas":[NSMutableArray new]}];
                [self.recentContactsDataSource addObject:itemSection];
            }
            [[itemSection valueForKey:@"datas"] addObject:item];
        }
        [db close];
        [self.tableView reloadData];
    }

}
-(void) registerNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setup) name:PRESENT_DIAL_VIEW_NOTIFICATION object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.recentContactsDataSource count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.recentContactsDataSource[section] valueForKey:@"datas"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.recentContactsDataSource[section] valueForKey:@"time"];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Call Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    IMRecentContactItem* record = [self.recentContactsDataSource[indexPath.section] valueForKey:@"datas"][indexPath.row];
    UIImageView* avatarView = (UIImageView*)[cell.contentView viewWithTag:1];
    UILabel* nameLabel = (UILabel*) [cell.contentView viewWithTag:2];
    UILabel* numberLabel = (UILabel*) [cell.contentView viewWithTag:3];
    UIImageView* statusView = (UIImageView*) [cell.contentView viewWithTag:4];
    [avatarView setImageWithURL:[NSURL URLWithString:record.peerAvatar] placeholderImage:[UIImage imageNamed:@"peerAvatar"]];
    [nameLabel setText:record.peerNick];
    [numberLabel setText:record.peerNumber];
    [statusView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_ico",record.status]]];
     
    return cell;
}

@end
