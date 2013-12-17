//
//  ContactCell.h
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactCellTopView.h"
#import "NXImageView.h"
@class ItelUser;
@interface ContactCell : UITableViewCell<UIScrollViewDelegate>
@property  (nonatomic,strong) IBOutlet UILabel *lbNickName;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property  (nonatomic,strong) UILabel *lbAlias;
@property  (nonatomic,strong) IBOutlet UILabel *lbItelNumber;
@property  (nonatomic,strong) IBOutlet NXImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnPush;

@property (nonatomic,strong) IBOutlet ContactCellTopView *topView;
@property (nonatomic) float currenTranslate;
@property (nonatomic ,strong) UILabel *lbCall;
@property (nonatomic ,strong) UILabel *lbSend;
@property (nonatomic ,weak)   ItelUser *user;
- (id)setup;
@end
