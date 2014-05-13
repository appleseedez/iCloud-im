//
//  AddressBookTableViewController.h
//  itelNSC
//
//  Created by nsc on 14-5-13.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "AddressCell.h"
@class ContactViewModel;
@class AddressService;


@interface AddressBookTableViewController : UITableViewController <AddressCellDelegate,MFMessageComposeViewControllerDelegate>
@property  (nonatomic,weak) AddressService *service;
@property (nonatomic)  ContactViewModel *contactViewModel;
@end
