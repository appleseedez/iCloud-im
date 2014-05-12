//
//  ContactCell.h
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItelUser;
@interface ContactCell : UITableViewCell
@property  (nonatomic,strong) IBOutlet UILabel *lbNickName;

@property  (nonatomic,strong) UILabel *lbAlias;
@property  (nonatomic,strong) IBOutlet UILabel *lbItelNumber;
@property  (nonatomic,strong) IBOutlet UIImageView *imgPhoto;




@property (nonatomic ,strong) UILabel *lbCall;
@property (nonatomic ,strong) UILabel *lbSend;
@property (nonatomic ,strong)   ItelUser *user;
- (id)setup;
@end
