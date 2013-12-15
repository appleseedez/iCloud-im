//
//  PersonRegButton.m
//  iCloudPhone
//
//  Created by nsc on 13-12-14.
//  Copyright (c) 2013年 NX. All rights reserved.
//

#import "PersonRegButton.h"

@implementation PersonRegButton

-(void)setUI{
    
    self.logo=[[UIImageView alloc]initWithFrame:CGRectMake(80, 10, 24, 22.5)];
    [self addSubview:self.logo];
    self.backgroundColor=self.normal;
    self.bounds=CGRectMake(0, 0, 310, 44.5);
    //[self setTitle:@"下一步" forState:UIControlStateNormal];
    [self addTarget:self action:@selector(changBackGroundHigh) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(changBackGroundNormal) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(changBackGroundNormal) forControlEvents:UIControlEventTouchUpOutside];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.layer setCornerRadius:5.0];
}
-(void)changBackGroundNormal{
    
    self.backgroundColor=self.normal;
    
}
-(void)changBackGroundHigh{
    
    
    
    self.backgroundColor=self.high;
    
}

@end
