//
//  IMRecentContactDetailsViewController.h
//  iCloudPhone
//
//  Created by Pharaoh on 12/30/13.
//  Copyright (c) 2013 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recent.h"
#import "Recent+CRUD.h"
@interface IMRecentContactDetailsViewController : UITableViewController
//@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic) Recent* currentRecent; //
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;

@end
