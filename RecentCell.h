//
//  RecentCell.h
//  itelNSC
//
//  Created by nsc on 14-7-3.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *nickName;
@property (weak, nonatomic) IBOutlet UILabel *peerItel;
@property (weak, nonatomic) IBOutlet UIImageView *imgType;

@end
