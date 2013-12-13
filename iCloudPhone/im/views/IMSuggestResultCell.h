//
//  IMSuggestResultCell.h
//  im
//
//  Created by Pharaoh on 13-12-12.
//  Copyright (c) 2013年 itelland. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMSuggestResultCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
