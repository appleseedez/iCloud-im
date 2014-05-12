//
//  UserViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItelUser.h"
@class ContactUserViewModel;
@interface UserViewController : UIViewController <UIAlertViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) ItelUser *user;
@property (nonatomic,strong) ContactUserViewModel *userViewModel;
@end
