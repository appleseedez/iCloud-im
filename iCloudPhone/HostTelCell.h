//
//  HostTelCell.h
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostCell.h"
@interface HostTelCell : UITableViewCell <HostCell>

@property (weak, nonatomic) IBOutlet UILabel *telLabel;
@end