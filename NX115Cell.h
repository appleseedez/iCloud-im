//
//  NX115Cell.h
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXImageView.h"
@interface NX115Cell : UITableViewCell

-(void)setPro:(NSDictionary*)pro;
@property (weak, nonatomic) IBOutlet NXImageView *image115;
@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UILabel *txtItel;

@end
