//
//  AddressBookViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-17.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBook.h"
#import <MessageUI/MessageUI.h>
#import "AddressBookCell.h"
@interface AddressBookViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,MFMessageComposeViewControllerDelegate,addressCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
