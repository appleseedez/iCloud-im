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
@interface IMRecentContactDetailsViewController ()

@end

@implementation IMRecentContactDetailsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
//self.tableView.tableHeaderView = self.headerView;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - life
- (void) setup{
    [self.avatarView setImageWithURL:[NSURL URLWithString:self.currentRecent.peerAvatar] placeholderImage:[UIImage imageNamed:@"peerAvatar"]];
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
    
    return cell;
}

- (void) setupFetchViewController{
    if ([IMCoreDataManager defaulManager].managedObjectContext) {
        // 获取最近通话记录列表
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recent"];
        [request setFetchBatchSize:20];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"createDate" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"peerNumber = %@", self.currentRecent.peerNumber];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:[IMCoreDataManager defaulManager].managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}
@end
