//
//  Detail115Cell.h
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Detail115Cell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbDetail;
-(void)setPro:(NSDictionary*)pro;
@end
