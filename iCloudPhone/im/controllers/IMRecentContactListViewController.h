//
//  IMRecentContactListViewController.h
//  im
//
//  Created by Pharaoh on 13-12-6.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
@interface IMRecentContactListViewController : CoreDataTableViewController <UIActionSheetDelegate>
- (IBAction)deleteAllRecents:(UIBarButtonItem*)sender;
@end
