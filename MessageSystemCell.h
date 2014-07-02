//
//  MessageSystemCell.h
//  itelNSC
//
//  Created by nsc on 14-6-30.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageImageView.h"
@interface MessageSystemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet MessageImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbContent;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;

@end
