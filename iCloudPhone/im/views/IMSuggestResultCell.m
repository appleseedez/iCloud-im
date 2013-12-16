//
//  IMSuggestResultCell.m
//  im
//
//  Created by Pharaoh on 13-12-12.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import "IMSuggestResultCell.h"

@implementation IMSuggestResultCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib{
    self.avatarView.layer.masksToBounds = YES;
    self.avatarView.layer.cornerRadius = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
