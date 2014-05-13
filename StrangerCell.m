//
//  StrangerCell.m
//  iCloudPhone
//
//  Created by nsc on 13-11-26.
//  Copyright (c) 2013年 nsc. All rights reserved.
//

#import "StrangerCell.h"

@implementation StrangerCell


-(void)awakeFromNib{
    [super awakeFromNib];
    self.lbNickName=[[UILabel alloc]init];
    self.lbNickName.frame=CGRectMake(65, 6, 80, 25);
    self.lbNickName.backgroundColor=[UIColor clearColor];
    
    [self addSubview:self.lbNickName];
    
    self.lbItelNumber=[[UILabel alloc] init];
    self.lbItelNumber.frame=CGRectMake(65, 20, 220, 40);
    self.lbItelNumber.backgroundColor=[UIColor clearColor];
    
    [self.lbItelNumber setFont:[UIFont fontWithName:@"HeiTi SC" size:12]];
    self.lbItelNumber.numberOfLines=0;
    [self.lbItelNumber setTextColor:[UIColor grayColor]];
    [self addSubview:self.lbItelNumber];
    
    self.imgPhoto=[[UIImageView alloc]initWithFrame:CGRectMake(6, 5, 55, 55)];
    
    [self.imgPhoto.layer setBorderWidth:3.0];
    [self.imgPhoto.layer setCornerRadius:self.imgPhoto.frame.size.width/4.0];
    [self.imgPhoto.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.imgPhoto.clipsToBounds=YES;
    [self.contentView addSubview:self.imgPhoto];
}

@end
