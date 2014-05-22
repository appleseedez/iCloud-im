//
//  MoreBlackListCell.m
//  itelNSC
//
//  Created by nsc on 14-5-21.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import "MoreBlackListCell.h"
#import "ItelUser+CRUD.h"
#import "MoreBlackLisetViewModel.h"
@implementation MoreBlackListCell

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
- (IBAction)remove:(id)sender {
    [self.blackViewModel removeFromBlackList:self.user.itelNum];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
