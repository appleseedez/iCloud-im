//
//  DialTableViewCell.h
//  DIalViewSence
//
//  Created by nsc on 14-4-29.
//  Copyright (c) 2014年 reactiveCocoa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *lbNickname;
@property (weak, nonatomic) IBOutlet UILabel *lbItelNumber;
-(void)setPro:(NSDictionary*)pro;
@end
