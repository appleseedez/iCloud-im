//
//  NX115Cell.m
//  iCloudPhone
//
//  Created by nsc on 14-2-12.
//  Copyright (c) 2014年 NX. All rights reserved.
//

#import "NX115Cell.h"
#import "UIImageView+AFNetworking.h"
@implementation NX115Cell

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
    NSString *nickName=[pro objectForKey:@"nick_name"];
    NSString *itel=[pro objectForKey:@"itel"];
    NSString *photo=[pro objectForKey:@"photo_file_name"];
    if (![nickName isEqual:[NSNull null]]) {
         self.txtName.text=nickName;
    }else{
        self.txtName.text=@"";
    }
    if ([photo isEqual:[NSNull null]]) {
        
    }else{
        [self.image115 setImageWithURL:[NSURL URLWithString:photo] ];
    }
    self.txtItel.text=[NSString stringWithFormat:@"iTel号码:%@",itel];
    
    
}
@end
