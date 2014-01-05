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
//    UIImageView* avatar = (UIImageView*) [self.headerView viewWithTag:1];
//    [avatar setImageWithURL:[NSURL URLWithString:self.currentRecent.peerAvatar] placeholderImage:[UIImage imageNamed:@"peerAvatar"]];
//    UILabel* nameLabel = (UILabel*) [self.headerView viewWithTag:2];
//    nameLabel.text = self.currentRecent.peerRealName;
//    UILabel* nickLabel = (UILabel*) [self.headerView viewWithTag:3];
//    nickLabel.text = [NSString stringWithFormat:@"(%@)",self.currentRecent.peerNick] ;
//    UILabel* numberLabel = (UILabel*) [self.headerView viewWithTag:4];
//    numberLabel.text = self.currentRecent.peerNumber;
//        self.tableView.tableHeaderView = self.headerView;
//    self.headerView = Nil;
}

- (void) tearDown{
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 111;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.detailTextLabel.text = @"test";
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
