//
//  UserViewController.h
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItelUser.h"
#import "BaseViewController.h"
@interface UserViewController : BaseViewController <UIAlertViewDelegate,UIActionSheetDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) ItelUser *user;
@end
