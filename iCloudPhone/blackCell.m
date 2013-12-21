//
//  blackCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-20.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "blackCell.h"
#import "ItelAction.h"
@implementation blackCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setUser:(ItelUser*)user{
    self.lbNickName.text=user.nickName;
    self.lbItel.text = user.itelNum;
    [self.btnRemove addTarget:self action:@selector(removeUser:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)removeUser:(ItelUser*)user{
    [[ItelAction action] delFriendFromBlack:self.lbItel.text];
}
@end
