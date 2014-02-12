//
//  List115ViewController.h
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "BaseViewController.h"

@interface List115ViewController : BaseViewController <UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *arrList;
@end
