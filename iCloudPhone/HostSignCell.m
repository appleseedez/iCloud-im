//
//  HostSignCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostSignCell.h"
#import "HostItelUser.h"
@implementation HostSignCell

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
-(void)showSettingView:(UIViewController *)viewController{
    
}
-(void)setPro:(HostItelUser *)host{
    self.signLabel.text =host.personalitySignature;
}
@end
