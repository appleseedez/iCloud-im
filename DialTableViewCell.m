//
//  DialTableViewCell.m
//  DIalViewSence
//
//  Created by nsc on 14-4-29.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "DialTableViewCell.h"

@implementation DialTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}
-(void)setPro:(NSDictionary*)pro{
    self.headImage.image= [pro objectForKey:@"image"];
    self.lbNickname.text=[pro objectForKey:@"nickname"];
    self.lbItelNumber.text=[pro objectForKey:@"itel"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
