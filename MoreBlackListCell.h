//
//  MoreBlackListCell.h
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  ItelUser ;
@class  MoreBlackLisetViewModel;
@interface MoreBlackListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *blNickname;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *lbItel;
@property (nonatomic)    ItelUser *user;
@property (weak,nonatomic)  MoreBlackLisetViewModel *blackViewModel;
@end
