//
//  HostHeadImageCell.h
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostCell.h"
#import "NXImageView.h"
@interface HostHeadImageCell : UITableViewCell<HostCell>
@property (weak, nonatomic) IBOutlet NXImageView *betterFaceImage;
@end
