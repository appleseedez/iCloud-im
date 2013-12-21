//
//  blackCell.h
//  iCloudPhone
//
//  Created by nsc on 13-12-20.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ItelUser;
@interface blackCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *lbNickName;
@property (weak, nonatomic) IBOutlet UILabel *lbItel;
@property (weak, nonatomic) IBOutlet UIButton *btnRemove;
-(void)setUser:(ItelUser*)user;
@end
