//
//  HostAddressCell.m
//  iCloudPhone
//
//  Created by nsc on 13-12-18.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "HostAddressCell.h"
#import "Area+toString.h"
#import <CoreData/CoreData.h>

#import "IMCoreDataManager.h"
@implementation HostAddressCell

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
    Area *area=[Area idForArea:host.address];
    NSString *address=area.toString;
    if (area!=nil) {
        self.addressLable.text=address;
        
    }
    
}
@end
