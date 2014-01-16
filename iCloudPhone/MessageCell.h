//
//  MessageCell.h
//  iCloudPhone
//
//  Created by nsc on 13-12-31.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NXImageView.h"
#import "NewMessageView.h"
@interface MessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NXImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbTittle;
@property (weak, nonatomic) IBOutlet UILabel *lbBody;
@property (strong,nonatomic) NewMessageView *newMessage;
@end
