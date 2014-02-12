//
//  Detail115Cell.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "Detail115Cell.h"

@implementation Detail115Cell

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
-(void)setPro:(NSDictionary*)pro{
    NSString *title=[pro objectForKey:@"title"];
    NSString *detail=[pro objectForKey:@"detail"];
    if (![title isEqual:[NSNull null]]) {
        self.lbTitle.text=title;
    }else{
        self.lbTitle.text=@"";
    }
    if (![detail isEqual:[NSNull null]]) {
        self.lbDetail.text=detail;
    }else{
        self.lbDetail.text=@"";
    }
    
    }
@end
