//
//  HostQQCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-20.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostQQCell.h"

@implementation HostQQCell

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
-(void)setPro:(HostItelUser *)host{
    self.QQLabel.text=host.QQ;
}
@end
